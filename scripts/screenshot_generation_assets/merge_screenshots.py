import sys
from PIL import Image
import os

padding = 100

def add_margin(pil_img, top, right, bottom, left, color):
    width, height = pil_img.size
    new_width = width + right + left
    new_height = height + top + bottom
    result = Image.new(pil_img.mode, (new_width, new_height), color)
    result.paste(pil_img, (left, top))
    return result

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
      (imgWidth, imgHeight) = img.size
      # calculate width
      stitched_gallery_width = (len(filePaths)) * imgWidth + padding * (len(filePaths))
      # create Image instance
      stitched_gallery = Image.new('RGB', (stitched_gallery_width, imgHeight), (235, 235, 235))
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

# example path: /Users/kallirroiretzepi/Documents/code/android-lantern/screenshots/en_US
dirPath = sys.argv[1]
# create stitched/ directory
stichedDirPath = dirPath + "/stitched"
try: 
  os.mkdir(stichedDirPath)
except: 
  print(stichedDirPath, "folder exists")

for subdir, dirs, files in os.walk(dirPath):
  for directory in dirs:
    if (directory != "stitched"): 
      result = merge_images_from_dir(dirPath + "/" + directory) 
      if result is not None:
        try:
          stitchedLocale = stichedDirPath + "/" + directory.split("/")[-1]
          print("saving", stitchedLocale)
          padded_result = add_margin(result, padding, 0, padding, padding, (235, 235, 235))
          padded_result.save(stitchedLocale+"_stitched.png") 
        except:
          print("something went wrong with", stitchedLocale)
