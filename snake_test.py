#!/usr/bin/env python3
import sys
import snakemake
from snakemake import parser, logging, exceptions


def main(argv=None):
    """Main entry point."""
    logging.setup_logger()
    try:
        parser, args = parser.parse_args(argv)
        success = parser.args_to_api(args, parser)
    except Exception as e:
        #exceptions.print_exception(e)
        print("Nope")
        sys.exit(1)
    sys.exit(0 if success else 1)

if __name__ == "__main__":
    main()