from os import getenv

#Database info

MONGODB_HOST = getenv('MONGODB_HOST', 'localhost')
MONGODB_PORT = getenv('MONGODB_PORT', 27017)
MONGODB_PASSWORD = getenv('MONGODB_PASSWORD', '')
MONGODB_DB = getenv('MONGODB_DB', 0)