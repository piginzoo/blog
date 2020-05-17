# -*- coding: utf-8 -*-
# clipboard2.py
import time
from AppKit import NSPasteboard, NSPasteboardTypePNG, NSPasteboardTypeTIFF
import os
BLOG = '/Users/piginzoo/workspace/blog/images/'

def get_today_path():
    #print "get_today_path"
    date_str = time.strftime('%Y%m%d',time.localtime(time.time()))
    

    full_path = BLOG+date_str
    #print full_path
    isExists=os.path.exists(full_path)
    if not isExists:
        os.makedirs(full_path)

    return date_str

def copy_to_blog(img_path):

    #print "copy to blog"
    #print img_path
    img_input = file(img_path, 'rb')
    name = os.path.basename(img_input.name)
    folder_path = get_today_path() + "/"
    image_path = BLOG + "/" + folder_path +  name

    img_output = file(image_path, 'wb')
    img_output.writelines(img_input.readlines())
    return '![](/images/' + folder_path + name + '){:class="myimg"}'

def get_paste_img_file():

    pb = NSPasteboard.generalPasteboard()
    data_type = pb.types()
    # if img file
    #print data_type
    now = int(time.time() * 1000) # used for filename
    if NSPasteboardTypePNG in data_type:
        #print "NSPasteboardTypePNG"
        # png
        data = pb.dataForType_(NSPasteboardTypePNG)

        png_filename = '%s.png' % now
        png_filepath = '/tmp/%s' % png_filename

        jpg_filename = '%s.jpg' % now
        jpg_filepath = '/tmp/%s' % jpg_filename

        ret = data.writeToFile_atomically_(png_filepath, False)

        import os
        # covert png to jpg
        os.system("sips -s format jpeg --out %s %s>/dev/null" % (jpg_filepath, png_filepath))

        if ret:
            return jpg_filepath
    elif NSPasteboardTypeTIFF in data_type:
        #print "NSPasteboardTypeTIFF"
        # tiff
        data = pb.dataForType_(NSPasteboardTypeTIFF)
        filename = '%s.tiff' % now
        filepath = '/tmp/%s' % filename
        ret = data.writeToFile_atomically_(filepath, False)
        if ret:
            return filepath
    elif NSPasteboardTypeString in data_type:
        #print "NSPasteboardTypeString"
        # string todo, recognise url of png & jpg
        pass

if __name__ == '__main__':
    #print(get_paste_img_file())
    print(copy_to_blog(get_paste_img_file()))
