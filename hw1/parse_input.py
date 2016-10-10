import csv
import fileinput
import sys
import re


# csv header
# title,author,release_date,ebook_id,language,body


class CsvField(object):
    def __init__(self):
        null = 'null'
        self.title = null
        self.author = null
        self.release_date = null
        self.ebook_id = null
        self.language = null
        self.body_list = []


matchers = [
    (r'Title: (.*)\b', 'title'),
    (r'Author: (.*)\b', 'author'),
    (r'Release Date: (.*) \[EBook #(\d+)\]', ['release_date', 'ebook_id']),
    (r'Language: (.*)\b', 'language'),
]


def main():
    read_body = False
    csv_field = CsvField()

    csv.field_size_limit(sys.maxint)
    csv_writer = csv.writer(sys.stdout)

    for line in fileinput.input():
        if read_body:
            if line.startswith('*** END OF THE PROJECT GUTENBERG EBOOK'):
                read_body = False
                csv_writer.writerow([
                    csv_field.title,
                    csv_field.author,
                    csv_field.release_date,
                    csv_field.ebook_id,
                    csv_field.language,
                    ''.join(csv_field.body_list),
                ])
                csv_field = CsvField()
            else:
                csv_field.body_list.append(line)
                for token in re.findall('[a-zA-Z]+', line):
                    sys.stderr.write("{},{}\r\n".format(csv_field.ebook_id, token.lower()))
        else:
            if line.startswith('*** START OF THE PROJECT GUTENBERG EBOOK'):
                read_body = True

            for matcher in matchers:
                match = re.match(matcher[0], line)
                if match:
                    fields = matcher[1]
                    if not isinstance(fields, list):
                        fields = [fields]
                    for idx, field in enumerate(fields):
                        setattr(csv_field, field, match.group(idx + 1))
                    break


if __name__ == '__main__':
    main()
