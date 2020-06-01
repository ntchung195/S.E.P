import os
import sys
sys.path.append('..')
print(os.path.abspath("static/user_voice/1.txt"))
os.mkdir(os.path.abspath("../static/user_voice")+'/test')
print(os.path.isdir("../static/user_voice"))
with open("../static/user_voice/1.txt", 'w') as f:
    data = 'some data to be written to the file'
    f.write(data)
    f.close()  