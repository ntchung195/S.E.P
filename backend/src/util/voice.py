# import dependencies for voice biometrics
import pyaudio
import pickle
# from IPython.display import Audio, display, clear_output
import wave
import numpy
from scipy.io.wavfile import read
from sklearn.mixture import GaussianMixture   #GMM 
import warnings
warnings.filterwarnings("ignore")

from sklearn import preprocessing
from python_speech_features import mfcc
import os



def extract_features(rate, signal):
    print("[extract_features] : Exctracting featureses ...")

    mfcc_feat = mfcc(signal,
                     rate,
                     winlen=0.020,  # remove if not requred
                     preemph=0.95,
                     numcep=20,
                     nfft=1024,
                     ceplifter=15,
                     highfreq=6000,
                     nfilt=55,

                     appendEnergy=False)

    mfcc_feat = preprocessing.scale(mfcc_feat)

    delta_feat = calculate_delta(mfcc_feat)

    combined_features = numpy.hstack((mfcc_feat, delta_feat))

    return combined_features


def calculate_delta(array):
    """Calculate and returns the delta of given feature vector matrix
    (https://appliedmachinelearning.blog/2017/11/14/spoken-speaker-identification-based-on-gaussian-mixture-models-python-implementation/)"""

    print("[Delta] : Calculating delta")

    rows, cols = array.shape
    deltas = numpy.zeros((rows, 20))
    N = 2
    for i in range(rows):
        index = []
        j = 1
        while j <= N:
            if i-j < 0:
                first = 0
            else:
                first = i-j
            if i+j > rows - 1:
                second = rows - 1
            else:
                second = i+j
            index.append((second, first))
            j += 1
        deltas[i] = (array[index[0][0]]-array[index[0][1]] +
                     (2 * (array[index[1][0]]-array[index[1][1]]))) / 10
    return deltas

def vectorize_voice(user_directory,user_id,logging,tag=None):
    if not os.path.isdir(user_directory):
        return False
    directory = os.fsencode(user_directory)
    features = numpy.asarray(())

    for file in os.listdir(directory):
        filename_wav = os.fsdecode(file)
        if filename_wav.endswith(".wav"):
            logging.info("Reading audio files for processing ...")
            (rate, signal) = read(user_directory +'/'+filename_wav)

            extracted_features = extract_features(rate, signal)

            if features.size == 0:
                features = extracted_features
            else:
                features = numpy.vstack((features, extracted_features))

        else:
            continue


        # GaussianMixture Model
        logging.info("Building Gaussian Mixture Model ...")

        gmm = GaussianMixture(n_components=6,
                            max_iter=200,
                            covariance_type='diag',
                            n_init=3)

        gmm.fit(features)

        logging.debug("[ * ] Modeling completed for user :{0} with data point ={1}".format(user_id,str(features.shape)))
         
        logging.info("[ * ] Saving model object ...")
        if tag == None:
            pickle.dump(gmm, open(user_directory+'/{}.gmm'.format(user_id), "wb"), protocol=None)
        if tag == "recognize":
            pickle.dump(gmm, open(user_directory+'/{0}_{1}.gmm'.format(user_id,tag), "wb"), protocol=None)

        logging.info("[ * ] User has been successfully enrolled ...")

        features = numpy.asarray(())
        
        return True

def verify_model(register_gmm,regconize_wav,logging):
    is_User = False
    logging.info("The recognize wav dir : {}".format(regconize_wav))
    logging.info("The gmm model dir : {}".format(register_gmm))
    (rate, signal) = read(regconize_wav)
    extracted_features = extract_features(rate, signal)
    # gmm_models = [os.path.join(user_directory, user)
    #               for user in os.listdir(user_directory)
    #               if user.endswith('.gmm')]

    # Load the Gaussian user Models
    models = pickle.load(open(register_gmm, 'rb')) 

    # user_list = [user.split("/")[-1].split(".gmm")[0]
    #              for user in gmm_models]

    # log_likelihood = numpy.zeros(len(models))


    gmm = models  # checking with each model one by one
    scores = numpy.array(gmm.score(extracted_features))
    # log_likelihood[i] = scores.sum()
    # scores= numpy.exp(scores) / (numpy.exp(scores)).sum()
    logging.debug("Score respond : {}".format(str(scores)))
    
    log_likelihood = scores.sum()/100.00
    logging.debug("log_likelihood respond : {}".format(str(log_likelihood)))
    logging.debug("Score sum respond : {}".format(str(scores.sum())))

    if log_likelihood >= -0.452:
        is_User = True
    else:
        is_User = False

 

    return is_User,log_likelihood