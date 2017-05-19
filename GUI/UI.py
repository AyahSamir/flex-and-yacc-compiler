#created by hanaa mohamed
"""
    Simple GUI for compilers project
    which acts as a simple text editor and an interface for compiling the input file that contains the  code
    written in the designed language and displays whether it was successful or not  
    and if not it displays the errors
"""

from Application import *
root = Tk()
app = Application(master=root)
app.mainloop()

