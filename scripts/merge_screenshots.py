import sys
from PIL import Image
import os

def merge_images_from_dir(dirPath):
  for subsubdir, _, files in os.walk(dirPath):
    filePaths = []
    for file in files:
      filePath = os.path.join(subsubdir, file)
      if (filePath == ".DS_Store"):
        os.remove(file[0])

      if (filePath.endswith(".png")): 
        filePaths.append(filePath)

    if (len(filePaths) > 0):
      img = Image.open(filePaths[0])
      padding = 100
      (imgWidth, imgHeight) = img.size
      # calculate width
      stitched_gallery_width = (len(filePaths) - 1) * imgWidth + padding * (len(filePaths) - 1)
      # create Image instance
      stitched_gallery = Image.new('RGB', (stitched_gallery_width, imgHeight))
      index = 0

      # sort list alphabetically since sometimes the paths aren't parsed in order
      filePaths.sort()

      for filePath in filePaths:
        # read width and height of each file
        img = Image.open(filePath)
        # paste new image see more https://stackoverflow.com/questions/10657383/stitching-photos-together
        stitched_gallery.paste(im=img, box=(index * imgWidth + padding * index, 0))
        index +=1
      return stitched_gallery

# "/Users/kallirroiretzepi/Documents/code/android-lantern/screenshots/en_US"
dirPath = sys.argv[1]
for subdir, dirs, files in os.walk(dirPath):
  result = merge_images_from_dir(subdir) 
  if result is not None:
    try:
      result.save(subdir  + "_stitched.png") 
    except:
      print("something went wrong")
