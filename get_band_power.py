__author__ = 'Marcus Way | marcusway23@gmail.com'

from scipy.io import loadmat
matfile = loadmat('settings.mat', squeeze_me=True, struct_as_record=False)
bands = dict(matfile['settings'].BANDS.__dict__)
conditions = dict()
del bands['_fieldnames'] 
conditions = matfile['settings'].CONDITIONS
regions = matfile['settings'].REGIONS


def sub_files_to_dicts(globList, savefile=False):
    """
    This function is going to take all of the
    files given by the glob list and turn
    it into a list holding all of the data

    :param globList: A string i.e, 'ADHD*.csv'
                    to specify which files to
                    process
    """
    import csv
    import os
    import cPickle as pickle
    import glob
    from collections import defaultdict, OrderedDict
    import re

    sub_dict = defaultdict(dict)
    for fileName in glob.glob(globList):
        inFile = open(fileName, "rU")
        reader = csv.DictReader(inFile)


        # Populate the dictionary by summing over relative power values given
        # in the input file over the ranges given by the bands dictionary above
        for subject in reader:
            sub_dict[subject['sID']]['sID'] = subject['sID']
            condition, region = re.findall(r'e[oc]', os.path.basename(fileName))[-1], re.findall(
                r'[LR]?[FPO]', os.path.basename(fileName))[-1]
            for band in bands:
                key = "_".join([condition, region, band])
                sub_dict[subject['sID']][key] = \
                    sum(float(subject[freq]) for freq in subject
                        if freq and freq != 'sID' and bands[band][0] <= 
                        float(freq) < bands[band][1])

    ordered_sub_dict = OrderedDict(sorted(sub_dict.iteritems(), 
                                               key=lambda x: x[0]))
    if savefile:
        out = open("rel_power_dict.p", "w")
        pickle.dump(ordered_sub_dict, out)
        out.close()

    return ordered_sub_dict



        # Now for every subject, I want to
        # Get the power in each band.  Moreover,
        # I should like to

def write_thing(sub_dict, outfile, subList=None):

    """
    Writes the contents of a sub_dict dictionary
    of the form output by sub_files_to_dicts to 
    a .csv file specified by outfile. Optional parameter subList restricts
    the output to only include subjects whose ID numbers
    are included in the list. 
    """
    from itertools import product
    import csv

    if subList == None:
        subList = sub_dict.keys()

    fieldnames = ['sID'] + [ "_".join(x) for x in product(conditions, regions, bands)]
 
    writer = csv.DictWriter(outfile, fieldnames)
    writer.writeheader()
    writer.writerows(sub_dict.values())


if __name__ == '__main__':


    import cPickle as pickle
    from sys import argv

    dicts = sub_files_to_dicts(argv[1])
    with open(argv[2], 'w') as out:
        write_thing(dicts, out)
    print "Success!"

