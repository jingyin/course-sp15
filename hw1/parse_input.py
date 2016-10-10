import csv
import re
import sys


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
        self.token_list = []


title_prefix = 'Title: '
author_prefix = 'Author: '
release_date_prefix = 'Release Date: '
language_prefix = 'Language: '


def process_file(file_path):
    read_body = False
    csv_field = CsvField()

    csv.field_size_limit(sys.maxint)
    csv_writer = csv.writer(sys.stdout)

    with open(file_path, 'r') as f:
        for line in f:
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
                    sys.stderr.write(''.join([
                        '{},{}\r\n'.format(csv_field.ebook_id, token.lower()) for token in csv_field.token_list
                    ]))
                    csv_field = CsvField()
                else:
                    csv_field.body_list.append(line)
                    csv_field.token_list.extend(re.findall('[a-zA-Z]+', line))
            else:
                if line.startswith('*** START OF THE PROJECT GUTENBERG EBOOK'):
                    read_body = True
                elif line.startswith(title_prefix):
                    csv_field.title = line[len(title_prefix):].strip()
                elif line.startswith(author_prefix):
                    csv_field.author = line[len(author_prefix):].strip()
                elif line.startswith(release_date_prefix):
                    csv_field.release_date = line[len(release_date_prefix):line.index('[')].strip()
                    csv_field.ebook_id = line[line.index('#') + 1:line.index(']')]
                elif line.startswith(language_prefix):
                    csv_field.language = line[len(language_prefix):].strip()


def main():
    assert len(sys.argv) > 1
    process_file(sys.argv[1])


if __name__ == '__main__':
    main()
