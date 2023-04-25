"""
Django command to wait for the database to be available.
"""
import time
from psycopg2 import OperationalError as Psycopg2OpError
from django.db.utils import OperationalError
from django.core.management.base import BaseCommand


class Command(BaseCommand):
    """Django command to wait for database"""
    # calls handle method and then calls stdout to log message
    def handle(self, *args, **options):
        """Entrypoint for command"""
        self.stdout.write('Waiting for database...')
        # defines false to assume database is down
        db_up = False
        while not db_up:
            try:
                # Check if database up, if not, raises
                # one of the two errors in our except.
                self.check(databases=['default'])
                db_up = True
            except (Psycopg2OpError, OperationalError):
                self.stdout.write('Database unavailable, waiting 1 second...')
                time.sleep(1)
        # If we get here then those exceptions were not raised.
        self.stdout.write(self.style.SUCCESS('Database now available!'))
