from ast import If
import imagehash
from PIL import Image
import os
import sys 

rootdir = sys.argv[1]
paths_hashes = []

# create list of file paths and their hashes
for subdir, dirs, files in os.walk(rootdir):
    for file in files:
        filePath = os.path.join(subdir, file)
        if (filePath.endswith(".DS_Store")) | (filePath.endswith(".py")): 
          break
        fileHash = imagehash.average_hash(Image.open(filePath))
        paths_hashes.append([filePath, str(fileHash)])

# find and delete duplicates
prevHash = ""
for file in paths_hashes:
  currentHash = file[1]
  if (currentHash != prevHash):
    prevHash = currentHash
  else: 
    print("delete", file[0])
    os.remove(file[0])