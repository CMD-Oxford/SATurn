"""

 #1 Change line 106 in C:\Python33\Lib\site-packages\win32com\client\gencache.py from
     f=io.StringIO(data)
     to
     f=io.BytesIO()
     
     in method _LoadDicts()
     
 #2 Run python Setup.py build
 #3 The directory ScarabScribblerExe/ contains the complete package
"""

from cx_Freeze import setup,Executable

excludes = ['Tkinter']

setup(
    name = 'ABIConverter',
    version = '1',
    description = 'A ABIConverter utility',
    author = 'David R. Damerell and Brian Marsden',
    author_email = 'david.damerell@sgc.ox.ac.uk, brian.marsden@sgc.ox.ac.uk',
    options = {'build_exe': {'excludes':excludes, 'build_exe':'build/'}}, 
    executables = [Executable('ABIConverter.py')]
)