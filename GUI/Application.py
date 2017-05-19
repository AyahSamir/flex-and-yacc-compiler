#created by hanaa mohamed
"""
    Simple GUI for compilers project
    which acts as a simple text editor and an interface for compiling the input file that contains the  code
    written in the designed language and displays whether it was successful or not  
    and if not it displays the errors
"""

from tkinter import *
from tkinter import filedialog
import copy
import os
import subprocess


class Application(Frame):
    def __init__(self, master=None):
            Frame.__init__(self, master)
            self.master = master
            self.master.configure(background="#404040")
            self.master.grid_columnconfigure(0, weight=1)
            self.filename = None
            self.fileopen = False
            self.pack()
            self.exe_path = os.path.abspath("casper.exe")
            self.current_dir = os.path.dirname(os.path.realpath("casper.exe"))
            ## we should also define dimensions and colour
            self.master.geometry('1000x900')
            #self.master.resizable(width=False, height=False)
            self.master.title(" Casper ")
            ##defining some reserved words
            self.reserved_words = [
                'int ', 'INT ', 'float ', 'FLOAT ', 'bool ', ' BOOL ', 'char ', 'CHAR ', 'print', 'PRINT', ' break', ' BREAK', ' continue', ' CONTINUE',
                ' switch', ' SWITCH', 'void', 'VOID', ' if', 'IF', ' else', ' ELSE', 'while', 'WHILE' ,
                'for', 'FOR', ' do', 'DO ', ' function ', ' FUNCTION ', 'SWITCH', 'switch', 'case', 'CASE'
            ]
            self.special_characters = ['\r', '\n', '\t', '\b', "\0", "\f", "\v"]
            #self.numbers = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9']
            self.createWidgets()

    def _search(self,  tag=None, keyword=None,):
        pos = '1.0'
        while True:
            if tag is 'number' or 'string':
                count = IntVar()
                if tag is 'number':
                    keyword = r'\y[-+]?[0-9]*\.?[0-9]+([eE][-+]?[0-9]+)?\y'
                elif tag is 'string':
                    keyword = r'"[^"]*"'
                elif tag is 'char':
                    keyword = r"'[A-Za-z]'"
                idx = self.textdisplay.search(keyword, pos, END, count=count, regexp=True)
                pos = '{}+{}c'.format(idx,count.get())

            else:
                idx = self.textdisplay.search(keyword, pos, END)
                pos = '{}+{}c'.format(idx, len(keyword))

            if not idx:
                break
            self.textdisplay.tag_add(tag, idx, pos)


    def createWidgets(self):
        ## create the 3 required buttons and the required grids
        self.btnframe = Frame(self.master, bd=2, relief=RAISED)

        self.openBtn = Button(self.btnframe, text=" Open file ", height=3, bg="#4D4D4D", fg="white",\
                         command=self.openfile)
        self.openBtn.pack(side=LEFT, expand=True, fill="x")
        self.saveBtn = Button(self.btnframe, bg="#4D4D4D",fg="white", height=3, text=" Save file ",\
                         command= self.savefile)
        self.saveBtn.pack(side=LEFT, expand=True, fill="x")
        self.closeBtn = Button(self.btnframe, bg="#4D4D4D", fg="white", height=3, text=" Close file ",\
                          command=self.close)
        self.closeBtn.pack(side=LEFT, expand=True, fill="x")

        self.compileBtn = Button(self.btnframe, bg="#4D4D4D", fg="white", height=3, text="Compile",\
                          command=self.compile)
        self.compileBtn.pack(side=LEFT, expand=True, fill="x")

        self.debugBtn = Button(self.btnframe, bg="#4D4D4D", fg="white", height=3, text="Debug",\
                          command=self.debug)
        self.debugBtn.pack(side=LEFT, expand=True, fill="x")

        self.btnframe.pack(fill=X,padx=10, pady=10)

        self.txtframe = Frame(self.master, bd=5, relief=GROOVE)
        self.textdisplay = Text(self.txtframe, height=35)
        self.textdisplay.configure(background='#D3D3D3', foreground="#000000", font="12")
        self.textdisplay.pack(expand=True, fill="both")
        ##define some tags for highlighting specific text
        self.textdisplay.tag_config('reserved_word', foreground='red')
        self.textdisplay.tag_config('special_char', foreground='blue')
        self.textdisplay.tag_config('number', foreground='#800080')
        self.textdisplay.tag_config('string', foreground='green')
        self.textdisplay.tag_config('char', foreground='#000FFF')
        self.txtframe.pack(fill=X,padx=10, pady=10)


        ##And now a terminal like window for displaying results
        self.consoleframe = Frame(self.master, bd=2, relief=SUNKEN)
        self.console = Text(self.consoleframe)
        self.console.configure(background='#000000', foreground="#00FF00", font="10")
        self.console.pack(expand=True, fill="both")
        self.console.insert("end", " Casper > Hello ! let me help you compile what you want! \n")
        self.console.configure(state="disabled")
        self.consoleframe.pack(fill=X,padx=10, pady=10)

        #myvar = StringVar()
        #myvar.set('')
        #myvar.trace('w', self._highlight)

    ##callback associated with openBtn
    def openfile(self):
        if self.fileopen is True:
            self.old_file_name = copy.copy(self.filename)
        self.filename = filedialog.askopenfilename(filetypes=(("code files", "*.c"), ("text files", "*.txt"), \
                                                                                        ("all files", "*.*")))
        ## here we should write how text in the file will be handled
        if len(self.filename) < 1 :
            return
        if self.fileopen is True:
            self.textdisplay.delete('1.0', END)
            self.fileopen = False
            self.console.configure(state="normal")
            self.console.insert("end", " Casper > {} has been closed. \n".format(self.old_file_name))
            self.console.configure(state="disabled")
            self.console.see("end")
        self._display_file()
        self.fileopen = True
        self.console.configure(state="normal")
        self.console.insert("end", " Casper > {} has been opened \n".format(self.filename))
        self.console.configure(state="disabled")
        self.console.see("end")

    def debug(self):
        pass
    def _display_file(self):
        f = open(self.filename)
        self.textdisplay.insert(1.0, f.read())
        self._highlight()


    def _highlight(self):
        for k in self.reserved_words:
            self._search('reserved_word', k)
        for c in self.special_characters:
            self._search('special_char', c)
        self._search(tag='number')
        self._search(tag='string')
        self._search(tag='char')
        self.textdisplay.update_idletasks()


    ##callback associated with saveBtn
    def savefile(self):
        text = self.textdisplay.get("1.0",'end-1c')
        if len(text)<1 and self.fileopen is False:
            self.console.configure(state="normal")
            self.console.insert("end", " Casper > file is empty, can not be saved !\n")
            self.console.configure(state="disabled")
            self.console.see("end")
            return

        if self.fileopen is True:
            with open(self.filename, "w") as outf:
                outf.write(text)

        else:
            file = filedialog.asksaveasfile(mode='w', defaultextension=".txt")
            if file is None:
                return
            self.filename = file.name
            with open(self.filename, "w") as outf:
                outf.write(text)
            self.fileopen = True
        self.console.configure(state="normal")
        self.console.insert("end", " Casper > {} has been modified and saved \n".format(self.filename))
        self.console.configure(state="disabled")
        self.console.see("end")

    ##callback associated with compileBtn
    def compile(self):
        """
        the most important function of them all, it calls the compiler, gives it the code file as an argument,
        captures the ouput of the process and displays it on our terminal
        """
        if self.filename is None:
            self.console.configure(state="normal")
            self.console.insert("end", " Casper > Please open a file or save the file you are working on \n")
            self.console.configure(state="disabled")
            self.console.see("end")

        else:
            proc = subprocess.Popen([self.exe_path, self.filename],  stdout=subprocess.PIPE).communicate()[0]
            output = proc.decode("utf-8")
            if output is '':
                self.console.configure(state="normal")
                self.console.insert("end", " Casper > {} compiled Successfully. output file can be found at:{}/out.txt\n".format(self.filename,self.current_dir))
                self.console.configure(state="disabled")
                self.console.see("end")
            else:
                subprocess.call(["rm", "out.txt"]) # delete quadraples file it's of no use
                self.console.configure(state="normal")
                self.console.insert("end", " Casper > Oops ! {}  while compiling {} \n".format(output, self.filename))
                self.console.configure(state="disabled")
                self.console.see("end")

    def close(self):
        if self.fileopen is True:
            self.textdisplay.delete('1.0', END)
            self.fileopen = False
            self.console.configure(state="normal")
            self.console.insert("end", " Casper > {} has been closed. \n".format(self.filename))
            self.console.configure(state="disabled")
            self.console.see("end")
            self.filename = None
        else:
            self.console.configure(state="normal")
            self.console.insert("end", " Casper > No file is open to be closed. \n")
            self.console.configure(state="disabled")
            self.console.see("end")
