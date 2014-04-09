import sys
import os
import hashlib

def chunk_reader(fobj, chunk_size=1024):
    """Generator that reads a file in chunks of bytes"""
    while True:
        chunk = fobj.read(chunk_size)
        if not chunk:
            return
        yield chunk

def check_for_duplicates(paths, hash=hashlib.sha1):
    hashes = {}
    print paths
    for path in paths:
        print path
        for dirpath, dirnames, filenames in os.walk(path):
            for filename in filenames:
                sys.stdout.write('.')
                full_path = os.path.join(dirpath, filename)
                hashobj = hash()
                for chunk in chunk_reader(open(full_path, 'rb')):
                    hashobj.update(chunk)
                file_id = (hashobj.digest(), os.path.getsize(full_path))
                duplicate = hashes.get(file_id, None)
                if duplicate:
                    print "Duplicate found: %s and %s" % (full_path, duplicate)
                else:
                    hashes[file_id] = full_path


check_for_duplicates([r'C:\Biondo\ALOS_storage\BRUTAS\PRISM\ITEM_original'])
