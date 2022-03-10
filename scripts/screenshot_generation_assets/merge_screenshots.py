import sys
from PIL import Image
import os

padding = 100
ideal_width = 6260

# adds padding around the image
def pad_image(img, top, right, bottom, left, color):
  width, height = img.size
  new_width = width + right + left
  new_height = height + top + bottom
  result = Image.new(img.mode, (new_width, new_height), color)
  result.paste(img, (left, top))
  return result

# useful in case we have only one or two screenshots
def frame_image(img):
  width, height = img.size
  if (width < ideal_width * 0.7):
    # its probably too narrow, pad it up to ideal_width
    return pad_image(img, 0, int((ideal_width - width)/2), 0, int((ideal_width - width)/2), (235, 235, 235))
  return img

def merge_images_from_dir(dirPath):
  for subsubdir, _, files in os.walk(dirPath):
    filePaths = []

    # load all PNG files
    for file in files:
      filePath = os.path.join(subsubdir, file)
      if (filePath == ".DS_Store"):
        os.remove(file[0])

      if (filePath.endswith(".png")): 
        filePaths.append(filePath)

    if (len(filePaths) > 0):
      # sort list alphabetically since sometimes the paths aren't parsed in order
      filePaths.sort()

      img = Image.open(filePaths[0])
      (imgWidth, imgHeight) = img.size

      # calculate width of final mosaic
      stitched_gallery_width = (len(filePaths)) * imgWidth + padding * (len(filePaths))
      # create Image instance
      stitched_gallery = Image.new('RGB', (stitched_gallery_width, imgHeight), (235, 235, 235))
      index = 0

      for filePath in filePaths:
        # read width and height of each file
        img = Image.open(filePath)
        # paste new image see more https://stackoverflow.com/questions/10657383/stitching-photos-together
        stitched_gallery.paste(im=img, box=(index * imgWidth + padding * index, 0))
        index +=1
      return stitched_gallery

# example path: /Users/kallirroiretzepi/Documents/code/android-lantern/screenshots/en_US
# dirPath needs to be the locale folder
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
          padded = pad_image(result, padding, 0, padding, padding, (235, 235, 235))
          framed = frame_image(padded)
          framed.save(stitchedLocale+"_stitched.png") 
          print("padded, framed, saved", stitchedLocale)
        except:
          print("something went wrong with", stitchedLocale)
