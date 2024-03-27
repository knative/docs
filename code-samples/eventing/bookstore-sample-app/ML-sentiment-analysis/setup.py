from setuptools import setup, find_packages
from setuptools.command.install import install
import subprocess


class PostInstallCommand(install):
    """Post-installation for installation mode."""
    def run(self):
        # Call the superclass run method
        install.run(self)
        # Run the command to download the TextBlob corpora
        subprocess.call(['python', '-m', 'textblob.download_corpora', 'lite'])


setup(
    name="download_corpora",
    version="1.0",
    packages=find_packages(),
    cmdclass={
        'install': PostInstallCommand,
    }
)
