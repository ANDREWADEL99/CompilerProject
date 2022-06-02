import sys
import subprocess
from PyQt5 import QtGui
from PyQt5.QtGui import QFont, QIcon, QPixmap
from PyQt5.QtWidgets import *
from PyQt5.QtCore import *

class Window(QWidget):
    def __init__(self):
        super().__init__()
        self.setWindowTitle("Smart Compiler")
        self.setMinimumSize(1000,500)
        self.setStyleSheet("background-color: #fafafa;")
        
        
        self.build_button=QPushButton("RUN",self)
        self.build_button.setStyleSheet("color: white;  background-color: #808080")
        self.build_button.clicked.connect(self.build_button_handler)
        
        self.input_code_text_area = QPlainTextEdit(self)
        self.input_code_text_area.insertPlainText("Add your code here\n")
        self.input_code_text_area.setFont(QFont('Arial', 14))
        self.input_code_text_area.setStyleSheet("color: #000000;  background-color: #DCDCDC")


        self.output_quadruples_text_area = QPlainTextEdit(self)
        self.output_quadruples_text_area.setReadOnly(True)
        self.output_quadruples_text_area.setStyleSheet("color: #000000;  background-color: #DCDCDC")


        self.debug_console_text_area = QPlainTextEdit(self)
        self.debug_console_text_area.setReadOnly(True)
        self.debug_console_text_area.setFont(QFont('Arial', 10))
        self.debug_console_text_area.setStyleSheet("color: #FF0000;  background-color: #DCDCDC")

        self.browse_file=QPushButton("Import text to code",self)
        self.browse_file.setStyleSheet("color: white;  background-color: #808080")
        self.browse_file.clicked.connect(self.browse_file_handler)


        self.save_file=QPushButton("Export quadruples to text",self)
        self.save_file.setStyleSheet("color: white;  background-color: #808080")
        self.save_file.clicked.connect(self.save_file_handler)

        self.show_errors = QLabel(self)
        self.show_errors.setText("Error Console")
        self.show_errors.setAlignment(Qt.AlignCenter)
        self.show_errors.setFont(QFont('Bold', 15))
        
        layout = QGridLayout()
        layout.addWidget(self.build_button,0,0)
        layout.addWidget(self.input_code_text_area,1,0)
        layout.addWidget(self.output_quadruples_text_area,1,1)
        layout.addWidget(self.browse_file,2,0)
        layout.addWidget(self.save_file,2,1)
        layout.addWidget(self.show_errors,3,0,1,2)
        layout.addWidget(self.debug_console_text_area,5,0,1,2)

        self.setLayout(layout)

    def browse_file_handler(self):
      file_name=None
      file_name = QFileDialog.getOpenFileName(self, 'Open file')
      if file_name is not None:
        file=open(file_name[0],"r")
        self.input_code_text_area.setPlainText(file.read())

    def save_file_handler(self):
      file_name=None
      file_name = QFileDialog.getOpenFileName(self, 'Open file')
      if file_name is not None:
        file=open(file_name[0],"w")
        file.write( self.output_quadruples_text_area.toPlainText())
    def show_symbol_tables_handler(self):
        None
        
    def build_button_handler(self):
        with open("code.txt", "w") as code_file:
            code_file.write(str(self.input_code_text_area.toPlainText()))
        subprocess.call([r'run.bat'])
        error_file =open("error.txt","r")
        quadruples_file=open("output.txt","r")
        error_file=error_file.read()
        self.debug_console_text_area.setPlainText(error_file)
        quadruples_file=quadruples_file.read()
        self.output_quadruples_text_area.setPlainText(quadruples_file)
        
        


if __name__ == "__main__":
    app = QApplication(sys.argv)
    window = Window()
    window.show()
    app.exec_()


