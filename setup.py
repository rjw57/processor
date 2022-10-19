from setuptools import setup, find_packages

setup(
    name='processor',
    packages=find_packages(where='python'),
    package_dir={'': 'python'},
    entry_points={
        'console_scripts': [
            'pasm=processor.assembler:main',
        ],
    },
    install_requires=[
        'docopt',
        'lark',
    ],
)
