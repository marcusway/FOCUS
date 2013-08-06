__author__ = 'Marcus Way | marcusway23@gmail.com'

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
    import collections

    bands = {'delta': {'low': 1, 'high': 5}, 'theta': {'low': 5, 'high': 8},
             'alpha': {'low': 8, 'high': 12}, 'beta': {'low': 12, 'high': 30}}

    big_list = []
    sub_dict = {}

    for fileName in glob.glob(globList):
        # get condition/region info from file name



        regions = ['LF', 'RF', 'LP', 'RP', 'O']
        conditions = ['eo', 'ec']

        inFile = open(fileName, "rU")
        reader = csv.DictReader(inFile)

        # Build the general dictionary structure, which will be 
        # indexed by subject ID #, condition (eo/ec), region,
        # and frequency band in that order

        for subject in reader:
            if subject['sID'] not in sub_dict:
                sub_dict[subject['sID']] = {}
            for condition in conditions:
                if condition not in sub_dict[subject['sID']]:
                    sub_dict[subject['sID']][condition] = {}
                for region in regions:
                    if region not in sub_dict[subject['sID']][condition]:
                        sub_dict[subject['sID']][condition][region] = {}
                    for band in bands:
                        if band not in sub_dict[subject['sID']][condition][region]:
                            sub_dict[subject['sID']][condition][region][band] = ''

            # Populate the dictionary by summing over relative power values given
            # in the input file over the ranges given by the bands dictionary above

            condition, region = os.path.basename(fileName)[15:17], os.path.basename(fileName)[17:19].strip(".")
            for band in bands:
                sub_dict[subject['sID']][condition][region][band] = \
                    sum(float(subject[freq]) for freq in subject
                        if freq and freq != 'sID' and bands[band]['low'] <= 
                        float(freq) < bands[band]['high'])

    ordered_sub_dict = collections.OrderedDict(sorted(sub_dict.iteritems(), 
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

    if subList == None:
        subList = sub_dict.keys()

    bands = ['delta', 'theta', 'alpha', 'beta']
    regions = ['LF', 'RF', 'LP', 'RP', 'O']
    conditions = ['eo', 'ec']


    outfile.write('sID,')
    for condition in conditions:
        for region in regions:
            for band in bands:
                outfile.write(condition + "_" + region + "_" + band + ",")
    outfile.write("\n")

    for subject in subList:
        outfile.write(subject + ",")
        for condition in conditions:
            for region in regions:
                for band in bands:
                    outfile.write("%s," %(sub_dict[subject][condition][region][band]))
        outfile.write("\n")



if __name__ == '__main__':


    import cPickle as pickle
    from sys import argv

    dicts = sub_files_to_dicts(argv[1])
    with open(argv[2], 'w') as out:
        write_thing(dicts, out)

