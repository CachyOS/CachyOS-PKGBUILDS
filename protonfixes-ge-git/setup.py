""" Install the protonfixes package
"""
import glob
from setuptools import setup, find_packages

setup(
    name='protonfixes',
    version=1.0.15
    description='Protonfixes fork by GloriousEggroll',
    url='https://github.com/GloriousEggroll/protonfixes.git',
    author='Thomas Crider',
    author_email='gloriouseggroll@gmail.com',
    classifiers=[
        'Development Status :: 3 - Alpha',
        'Topic :: Games/Entertainment',
        'Operating System :: POSIX :: Linux',
        'License :: OSI Approved :: BSD License',
        ],
    keywords='proton steam winetricks protonfixes',
    packages=find_packages(),
    zip_safe=False,
    package_data={'protonfixes':['*.kv','gamefixes/verbs/*']},
)
