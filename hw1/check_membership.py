import fileinput
import sys


def main():
    assert len(sys.argv) > 1
    words = set(line.lower().strip() for line in fileinput.input())
    for line in sys.stdin:
        word = line[:line.index(',')]
        if word in words:
            sys.stdout.write(line)


if __name__ == '__main__':
    main()
