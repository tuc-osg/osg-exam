\newcommand*{\MyClassName}{osgexam}
\ProvidesClass{\MyClassName}[2021/06/14 0.2c ]
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
%% Diese Klasse hat zwei Funktionen:
%%  1. Erweiterung der exam-Klasse
%%  2. Konfigurator und Launcher für die Generierung von verschiedenen Typen
%%     von Dokumenten, die mit dieser Klasse generiert werden können.
%%     Dies entspricht den verschiedenen Modi.
%%
%% Mögliche Modi:
%% - exam:    leeres Aufgabenblatt zum händischen Ausfüllen
%% - single:    personalisiertes einzelnes Aufgabenblatt
%% - dummy: personalisiertes Aufgabenblatt mit Default-Daten
%% - develop: wie 'dummy', aber das PDF wird direkt im Arbeitverzeichnis
%%                 mit dem Namen des Quellfiles definiert.
%% - answers: Musterlösung
%% - series:     generiert personalisierte Aufgabenblätter aus einer xlsx-Datei
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% 2020-02-12: FIX: Anpassung an Update von openpyxl (get_sheet_names() ist deprecated)
% 2020-02-12: FIX: Robust gegen Leerzeichen in Excel-Tabellenheadern
% 2020-02-16: Prefix wird auch bei Seriendruck genutzt
% 2020-02-16: NEW: Option "passedwith" legt Prozentsatz fest, bei der die Prüfung
%                        bestanden ist (Vorgabe: 50)
%
% 2021-06-14: Version 0.2
%  - Umstellung auf pgf-Keys (da keyval-patch in MikTeX 2020 nicht mehr läuft)
%  - Option "answers" ist nun Wert von "development"
% 2021-01-03: FIX: empty-Document erzeugte Fehler
% 2022-07-12: NEW: Gruppen
% 2023-07-04: FIX+NEW: Gruppen bug, keine Gruppendeklaration mehr notwendig
% 2024-02-01: FIX: Für ID-Bezeichner in XL ist jetzt auch 'Matrikel' gültig
% 2025-01-23: WORK AROUND: vermuteter Polyglossia-Bug +
%              FIX: Für ID-Bezeichner in XL ist jetzt auch 'matrikel-nr.' gültig
%              FIX: Für Namens-Bezeichner in XL ist jetzt auch 'nachname' gültig
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
\newlinechar=`\^^J
\RequirePackage{iftex}               % für Test auf Lua(La)TeX
\ifLuaTeX
\else
\typeout{ ************************************************^^J
  * LuaLaTeX is required to compile this document. ^^J
  * Sorry! ^^J
   ************************************************
}
\expandafter\@@end\fi
\RequirePackage{luacode}
%\LuaCodeDebugOn
\RequirePackage{pgfopts}
\RequirePackage{etoolbox}
\newbool{osgexam@development}
\newbool{osgexam@seat}
\boolfalse{osgexam@seat}
\newbool{osgexam@seatisfile}
\boolfalse{osgexam@seatisfile}
\newbool{osgexam@group}
\newbool{osgexam@impolite}
\newbool{osgexam@autoseries}
%\def\@unknownkeys{}
\pgfkeys{
  /osgexam/.cd,
  development/.is choice,
  development/true/.code={
    \booltrue{osgexam@development}
    %\typeout{*** Developer mode}
  },
  development/false/.code={
    \boolfalse{osgexam@development}
  },
  development/.default=true,
  % Schaltet den Developer-Mode ein. (kann durch Definition eines Modes überschrieben werden)
  % Im Developer-Mode wird das "normale" LaTeX-Verhalten wieder hergestellt, d.h. es wird eine
  % (Dummy-)Version des Prüfungsbogens mit dem Namen der (Haupt-)Quelldatei generiert.
  development/answers/.code={
    \booltrue{osgexam@development}
    \def\osgexam@mode{answer}
    \PassOptionsToClass{answers}{exam}
    %\typeout{*** Developer/answer mode}
  },
  % bei developer=answers wird "answers" an die Exam-Klasse durchgereicht, sonst hat die
  % Option keine  Wirkung.
  prefix/.store in=\osgexam@prefix,
  prefix=,
                                % Prefix für die erzeugten Dateinamen (z.B. prefix="np" => Musterlösung heisst "np-solution.pdf") 
  xlsfile/.store in=\osgexam@xlsfile,
  xlsfile=,
                                % Excel-Datei, die für die Serienerzeugung von Prüfungen genutzt wird
  outpath/.store in=\osgexam@outpath,
  outpath=pdf,                                % Verzeichnis in dem erzeugte Dateien ausgegeben werden (außer im Developer-Mode) 
  seat/.is choice,
  seat/no/.code={\boolfalse{osgexam@seat}\boolfalse{osgexam@seatisfile}},
  seat/xls/.code={\booltrue{osgexam@seat}\booltrue{osgexam@seatisfile}},
  seat/title/.code={\booltrue{osgexam@seat}\boolfalse{osgexam@seatisfile}},
  group/.code=\booltrue{osgexam@group},             % Wird Gruppe auf Aufgabenbogen gedruckt?
  lang/.store in=\osgexam@lang,                            % Sprache 
  lang=de,
  solutiontime/.store in=\osgexam@solutiontime,  % Prüfungsdauer in Minuten
  solutiontime=90,          
  passedwith/.store in=\osgexam@passedwith,      % Prozentsatz, bei der eine Prüfung bestanden ist
  passedwith=50,
  impolite/.code=\booltrue{osgexam@impolite},     % Lässt Begrüssung und Erfolgswunsch weg (kann Platz sparen)
  autoseries/.code=\booltrue{osgexam@autoseries},           % Automatische Serien-Erstellung (Überspringen des Menüs.)
  quotes/.store in=\osgexam@quotes,                    % Steuert Interpretation von Anführungszeichen
  quotes=latex,
  % Die folgenden Optionen brauchen in der Regel nicht genutzt werden.
  % Die default*-Optionen setzen die Studentendaten für die Dummy-Modi,
  defaultfirstname/.store in=\osgexam@defaultfirstname,
  defaultfirstname=Max,
  defaultlastname/.store in=\osgexam@defaultlastname,
  defaultlastname=Mustermann,
  defaultstudentid/.store in=\osgexam@defaultstudentid,
  defaultstudentid=123456,
  defaultseat/.store in=\osgexam@defaultseat,
  defaultseat=123.45.6/12-A,
  defaultgroup/.store in=\osgexam@defaultgroup,
  defaultgroup=A,
  % Alle anderen Optionen werden direkt an die Exam-Klasse durchgereicht.
  .unknown/.code={
    %\typeout{*** Unknown option, pass to exam: \pgfkeyscurrentname}
    \PassOptionsToClass{\pgfkeyscurrentname}{exam}
    },
}                                
\ProcessPgfOptions{/osgexam}
\ifboolexpr{ bool{osgexam@development} and test{\ifundef{\mode}} }{
  \ClassWarning{\MyClassName}{developer mode active}
  \def\mode{develop}
}{
  \RequirePackage{ifplatform}          % für Test auf shell escape
  \ifshellescape
    \else
    \typeout{
      ************************************************^^J
      * No right to shell escape.^^J
      * Call lualatex with option '-shell-escape' ^^J
      * or use class option 'development'. ^^J
      ************************************************}
    \expandafter\@@end\fi
}
\newcommand*{\oex@processmenue}[1]{\directlua{
    if string.len("#1") > 0 then
      ndx=string.lower(string.sub("#1",1,1))
    else
      ndx="e"
    end
    menu={
      ["e"]="exam",
      ["a"]="answers",
      ["p"]="series",
      ["i"]="single",
      ["d"]="dummy",
      ["x"]="develop",
      ["q"]="quit",
    }
    if menu[ndx] == nil then
       tex.sprint(menu["e"])
    else
       tex.sprint(menu[ndx])
    end      
  }%
}
\newbool{oex@startover}
\newbool{oex@series}
\ifundef{\mode}{
  % Kein mode wurde definiert
  % series als Option gesetzt?
  \ifbool{osgexam@autoseries}{
    %=> setze mode entsprechend auf series und starte neu.
    \booltrue{oex@startover}
    \edef\osgexam@mode{series}
  }
  {
  % => frage am Terminal und starte neu 
  \typeout{**************************************************************************}
  \typein[\mode]{
    No mode provided.^^J Please enter a proper mode (default is 'e') ^^J
    - [e]mpty exam^^J
    - [a]nswers (solution)^^J
    - [p]ersonalized exam series from MS Excel file^^J
    - [i]ndividually personalized exam^^J
    - [d]ummy personalized exam^^J^^J
    - [q]uit
  }
  \booltrue{oex@startover}
  \edef\osgexam@mode{\oex@processmenue{\mode}}
  }
}{
  \edef\osgexam@mode{\mode}
}
\ifdefstring{\osgexam@mode}{quit}{
  % Abbruch
  %\typeout{***** \osgexam@mode ... bye,bye!}
  \@@end
}{}

% \ifdefstrequal aus der etoolbox scheint Probleme bei unterschiedlichen
% Levels of Expansion zu haben, daher definieren wir ein ähnliches Macro auf
% Grundlage von \pdfstrcmp.
% Da dies auch für Prüfungsautoren nützlich ist, ist dieses Macro öffentlich
\RequirePackage{pdftexcmds}
\newcommand{\ifstreq}[4]{%
  \ifnum\pdf@strcmp{#1}{#2}=0
  #3
  \else
  #4
  \fi
}
% Option "series" setzt Boolean
\ifdefstring{\osgexam@mode}{series}{
  \booltrue{oex@series}
}{}

%  Setzt Dummy-Daten
\def\oex@setdummy{
  \gdef\oex@studentid{\osgexam@defaultstudentid}
  \gdef\oex@studentfirstname{\osgexam@defaultfirstname}
  \gdef\oex@studentlastname{\osgexam@defaultlastname}
  \gdef\oex@seat{\osgexam@defaultseat}
  \gdef\oex@group{\osgexam@defaultgroup}
}
%%%%%%%%%%%%%% Mode: develop  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\ifdefstring{\osgexam@mode}{develop}{
  \gdef\studentname{\osgexam@defaultfirstname\ \osgexam@defaultlastname}
  \gdef\studentid{\osgexam@defaultstudentid}
  \gdef\seat{\osgexam@defaultseat}
  \gdef\studentgroup{\osgexam@defaultgroup}
}{}
%%%%%%%%%%%%%% Mode: exam (empty) %%%%%%%%%%%%%%%%%%%%%%%%%%
\ifdefstring{\osgexam@mode}{exam}{
  \ifdefstring{\osgexam@prefix}{}{
    \def\oexjob{empty}
  }{
    \def\oexjob{\osgexam@prefix-empty}
  }
  \ifstreq{\jobname}{\oexjob}{
    \gdef\studentid{ID:\hspace*{6ex}}
    \gdef\studentname{Name:\rule[-4ex]{0pt}{2ex}}
    \gdef\seat{~}
  }{
    \booltrue{oex@startover}
    \oex@setdummy
    \def\oex@mode{exam}
  }
}{}
%%%%%%%%%%%%%% Mode: answers (solution) %%%%%%%%%%%%%%%%%%%%
\ifstreq{\osgexam@mode}{answers}{
  \ifdefstring{\osgexam@prefix}{}{
    \def\oexjob{solution}
  }{
    \def\oexjob{\osgexam@prefix-solution}
  }
  \ifstreq{\jobname}{\oexjob}{
    \gdef\studentid{~}
    \gdef\studentname{~}
    \gdef\seat{ -- }
    \PassOptionsToClass{answers}{exam}
  }{
    \booltrue{oex@startover}
    \oex@setdummy
    \def\oex@mode{answers}
  }
}{}
%%%%%%%%%%%%%% Mode: single  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\ifdefstring{\osgexam@mode}{single}{
  \def\oex@mode{single}
  \ifundef{\studentid}{
    \booltrue{oex@startover}
    \typein[\id]{Student ID}
    \def\oex@studentid{\id}
    \ifdefstring{\osgexam@prefix}{}{
      \def\oexjob{\id}
    }{
      \def\oexjob{\osgexam@prefix-\id}
    }
  }{}
  \ifundef{\studentname}{
    \booltrue{oex@startover}
    \typein[\firstname]{Student's first name(s)}
    \typein[\lastname]{Student's last name}
    \def\oex@studentfirstname{\firstname}
    \def\oex@studentlastname{\lastname}
  }{}
  \ifbool{osgexam@seat}{
    \ifundef{\seat}{
      \booltrue{oex@startover}
      \typein[\seat]{Seat}
    }{
    }
    \def\oex@seat{\seat}
  }{
    \def\oex@seat{\osgexam@defaultseat} % dummy
  }
  \ifbool{osgexam@group}{
    \ifundef{\studentgroup}{
      \booltrue{oex@startover}
      \typein[\studentgroup]{Group}
    }{
    }
    \def\oex@group{\studentgroup}
  }{
    \def\oex@group{\osgexam@defaultgroup} % dummy
  }
}{}
%%%%%%%%%%%%%% Mode: dummy  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\ifdefstring{\osgexam@mode}{dummy}{
  \ifdefstring{\osgexam@prefix}{}{
    \def\oexjob{dummy}
  }{
    \def\oexjob{\osgexam@prefix-dummy}
  }
  %\typeout{***** Generate dummy *****}
  \def\oex@mode{dummy}
  \oex@setdummy
}{}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Python-Programm, um einzelne Prüfungsblätter oder eine
% Serie von Prüfungsblättern zu generieren.
% Durch Setzen des Jobnames wird gleich das korrekte PDF
% generiert.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\ifoex@startover
\begin{filecontents*}{\jobname.gen.py}
import sys
import os
import os.path
from subprocess import call
from openpyxl import load_workbook

def genexam(firstname, lastname, studentid, seat, group, mainfile, job, outpath, mode, prefix, force=False, useseat=False): 
    '''
    Generates an exam for the given student, if not existing.
    Target file is stored in "outpath", with the student ID as file name.
    '''
    #print("firstname ="+firstname)
    #print("lastname ="+lastname)
    #print("studentid ="+studentid)
    #print("seat ="+seat)
    #print("group ="+group)
    #print("mainfile ="+mainfile)
    #print("job ="+job)
    #print("outpath ="+outpath)
    #print("mode ="+mode)
    # safeguard for broken XLSX reading
    if not lastname or not firstname or not studentid:
        return
    targetfile = outpath + '/' + job + '.pdf'
    #print("Targetfile: "+targetfile)
    if not(force) and os.path.isfile(targetfile):
        print("Skipping generation of %s, because it exists ..." % targetfile)
        return
    print("Generating " + targetfile)
    if mode == 'single':
        if not prefix:
            if not useseat: 
               job = studentid
            else:
               job = seat
        else:
            if not useseat:
               job = prefix+'-'+studentid
            else:
               job = prefix+'-'+seat
    call('latexmk -C', shell=True)
    cmdline = 'latexmk -pdflua -enable-write18 -jobname={6} -outdir={7} -usepretex="\\def\\mode{{{8}}}\\def\\studentid{{{0}}}\\def\\studentname{{{1} {2}}}\\def\\seat{{{3}}}\\def\\studentgroup{{{4}}}" {5}'.format(
        studentid, firstname, lastname, seat, group, mainfile, job, outpath, mode
        )
    #print(cmdline)  
    call(cmdline, shell=True)
    # make clean
    cmdline = 'latexmk -c -pdflua -jobname={0} -outdir={2} {1}'.format(job, mainfile, outpath)
    call(cmdline, shell=True)

def students(xlsx_file):
    wb = load_workbook(filename=xlsx_file, read_only=True)
    sheets = wb.sheetnames
    ws = wb[sheets[0]]
    # find the starting row for the data and the columns for id, name and first name
    student_id_col = None
    first_name_col = None
    last_name_col = None
    seat_col = None
    group_col = None
    for row_index, row in enumerate(ws.iter_rows()):
        if student_id_col != None and first_name_col != None and last_name_col != None:
            student_id = str(ws.cell(row=row_index+1, column=student_id_col+1).value)
            first_name = ws.cell(row=row_index+1, column=first_name_col+1).value
            last_name = ws.cell(row=row_index+1, column=last_name_col+1).value
            if seat_col:
                seat = ws.cell(row=row_index+1, column=seat_col+1).value
            else:
                seat = '~'
            if group_col:
                group = ws.cell(row=row_index+1, column=group_col+1).value
            else:
                group = '~'
            if student_id != 'None':  # Might be None in empty rows
                yield first_name, last_name, student_id, seat, group
        else:
            for col_index, cell in enumerate(row):
                if str(cell.value).strip().lower() in ['matrikelnummer','matr-nr.','id','student id', 'matrikel', 'matrikel-nr.']:
                    student_id_col = col_index
                elif str(cell.value).strip().lower() in ['name', 'nachname', 'surname','family name']:
                    last_name_col = col_index
                elif str(cell.value).strip().lower() in ['vorname','first name','forename','given name']:
                    first_name_col = col_index
                elif str(cell.value).strip().lower() in ['sitz', 'platz','seat','place']:
                     seat_col = col_index
                elif str(cell.value).strip().lower() in ['gruppe', 'group']:
                     group_col = col_index
    
if sys.argv[1] == 'single':
    genexam(firstname=sys.argv[2],
                lastname=sys.argv[3],
                studentid=sys.argv[4],
                seat=sys.argv[5],
                group=sys.argv[6],
                mainfile=sys.argv[7],
                job=sys.argv[8],
                outpath=sys.argv[9] ,
                mode=sys.argv[10],
                prefix=sys.argv[11],
                force=(sys.argv[12]=="True"),
                useseat=(sys.argv[13]=="True")
#                useseat=True
)

    exit(0)

if sys.argv[1] == 'serie':
    for first_name, last_name, student_id, seat, group in students(sys.argv[2]):
                print("@@@@@@@@@@@@ useseat = ", sys.argv[6])
                genexam(firstname=first_name, 
                     lastname=last_name, 
                     studentid=student_id,
                     seat=seat,
                     group=group,
                     mainfile=sys.argv[3],
                     job=student_id,
                     outpath=sys.argv[4],
                     mode='single',
                     prefix=sys.argv[5],
                     force=False,
#                     useseat=True
                     useseat=(sys.argv[6]=="True")
                )
    exit(0)
\end{filecontents*}
\ifbool{oex@series}{
  % Überprüft Excel-Datei 
  \ifundef{\xlsfile}{
    \edef\xlsfile{\osgexam@xlsfile}
    \ifdefstring{\xlsfile}{}{
      \typeout{**************************************************************************}
      \typein[\xlsfile]{
        No XLS file given, please input file name.
      }
    }{}
  }{}
  \IfFileExists{\xlsfile}{
    %\typeout{***** Generate from "\xlsfile"}
    \ifbool{osgexam@seatisfile}{
      \directlua{os.execute("python3 \jobname.gen.py serie '\osgexam@xlsfile' '\jobname' '\osgexam@outpath' '\osgexam@prefix' True")}
    }{
      \directlua{os.execute("python3 \jobname.gen.py serie '\osgexam@xlsfile' '\jobname' '\osgexam@outpath' '\osgexam@prefix' False")}
    }
  }{
    % Kann Datei nicht finden => Fehler
    \ClassError{\MyClassName}{Can't find file '\xlsfile'.}{Provide a existing Excel file.}
  }
}{
  \ifbool{osgexam@seatisfile}{
    \directlua{os.execute("python3 \jobname.gen.py single '\oex@studentfirstname' '\oex@studentlastname' '\oex@studentid' '\oex@seat' '\oex@group'  '\jobname' '\oexjob' '\osgexam@outpath' '\oex@mode' '\osgexam@prefix' True True")}
  }{
    \directlua{os.execute("python3 \jobname.gen.py single '\oex@studentfirstname' '\oex@studentlastname' '\oex@studentid' '\oex@seat' '\oex@group'  '\jobname' '\oexjob' '\osgexam@outpath' '\oex@mode' '\osgexam@prefix' True False")}
  }
}
% hinterher aufräumen
\directlua{os.execute("rm \jobname.gen.py")}
% erzwingt Beendigung des Compiler-Laufs
\expandafter\@@end
\fi
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
%% Hier beginnt die eigentliche LaTeX-Klasse.
%% Optionen sind zu diesem Zeitpunkt aber schon verarbeitet.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%\DisableKeyvalOption{\MyClassName}{lang} % Optionen mit (möglicherweise) geschweiften Klammern verwirren "normale" Klassen/Pakete
%\LoadClass[twoside,addpoints]{exam}
\PassOptionsToClass{twoside,addpoints}{exam}
\LoadClass{exam}
\AtEndPreamble{
  \usepackage{fontspec}
  \setmainfont{PT Serif} %{etwa: Times New Roman}
  % ToDo: Passende Sans- und Mono-Fonts setzen?
}
%%%%%%%%%%%%%% Sprache %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%\RequirePackage[babelshorthands]{polyglossia}
\RequirePackage[babelshorthands]{polyglossia}
\setmainlanguage{english}
\setotherlanguages{english,german}
%% Work around für Polyglossia Problem
%% TODO: Evtl. muss die richtige Familie für PT Serive (rm?) übergeben werden
%% oder sogar alle \xxfamily-Macros gepatcht werden.
\providecommand{\familytype}{}

\ifstreq{\osgexam@quotes}{babelshorthands}{
  %\typeout{****** Option "babelshorthands"}
  \setmainlanguage{english}
  \define@boolkey{english}[english@]{babelshorthands}[true]{}
  \def\english@shorthands{%
    \def\language@group{english}%
    \bbl@activate{"}%
    \declare@shorthand{english}{"`}{\openautoquote}%
    \declare@shorthand{english}{"'}{\closeautoquote}
  }
  \AtEndPreamble{
    \setmainlanguage{english}
    \english@shorthands
   }
   \RequirePackage[autostyle=true,german=quotes,english=american]{csquotes} 
 }{
   \RequirePackage[autostyle=true,german=quotes,english=american]{csquotes} 
   \RequirePackage{polyglossia}
   \ifstreq{\osgexam@quotes}{ascii}{
     %\typeout{******* Quotes: ascii} 
     \AfterEndPreamble{
       \MakeOuterQuote{"}
       \EnableQuotes
     }
   }{
     % Option latex oder beliebiger Wert: Standardverhalten von LaTeX 
     %\typeout{******* Quotes: latex (\osgexam@quotes)}
   }
}
% Damit die Shorthands funktionieren, muss Deutsch als Standardsprache festgelegt werden (WTF?) Das wird später ggf. überschrieben.
%\setmainlanguage{german}
%\setotherlanguage{english}
% Die Sprachoption wird auf Einzelbooleans heruntergebrochen
\newbool{oex@lang@de} % Deutsch gesetzt
\newbool{oex@lang@en} % Englisch gesetzt
\newbool{oex@lang@twolanguages} % Es sind beide Sprachen gesetzt
% Je nach Sprachbefehl wird ein Kontext gebildet, in dem die Sprachen aktiv sind
\newbool{oex@active@de} % Deutsch ist aktiv
\newbool{oex@active@en} % Englisch ist aktiv
\newcommand{\lde}[1]{}
\newcommand{\len}[1]{}
% Einstellungen für Polyglossia
\newcommand{\oex@pg@settings}{}
% Die Sprachoption ("lang=..") kann geschweifte Klammern enthalten. Sie wird als Liste behandelt und mit dem
% Listenmechanismus von eToolBox zerlegt.
% Die Reihenfolge ist wichtig: die zurerst gelistete Sprache ist die Erstsprache.
% Texte in der Erstsprache erscheinen bei zweisprachigen Texten immer
% zuerst, 

\renewcommand*{\do}[1]{
  % Überprüfe, ob valides Sprachkürzel angegeben wurde
  \ifstreq{#1}{de}{}{
    \ifstreq{#1}{en}{}{
      \ClassError{\MyClassName}{unknown language '#1' in option}{Only 'de' and 'en' are allowed here.}
    }
  }
  \csuse{oex@lang@#1true} % Setzt das Boolean für die Sprachnutzung
  \csdef{l#1}##1{##1} % Definiere \lde bzw. \len
  \ifundef{\oex@frstlang}{ % Falls es die erste (und möglicherweise einzige) Sprachdefinition ist...
    \ifstreq{#1}{de}{ % ...setzt die Hauptsprache...
      \renewcommand{\oex@pg@settings}{
        \selectlanguage{german}
        \chqword{Aufgabe}
        \hqword{Aufgabe}
        \chpword{Punkte}
        \hpword{Punkte}
        \chtword{$\sum$}
        \htword{$\sum$}
        \chsword{Erreicht}
        \hsword{Erreicht}
        \chbpword{Bonus}
        \hqword{Aufgabe}
        \renewcommand{\solutiontitle}{\noindent\textbf{Lösung:}\par\smallskip}
      }
    }{
      \renewcommand{\oex@pg@settings}{
        \selectlanguage{english}
        \renewcommand{\solutiontitle}{\noindent\textbf{Solution:}\par\smallskip}
      }
    }
    \def\oex@frstlang{\csuse{oex@temp#1}} % ...und merke, dass es die Erstsprache ist
  }{ % Im Fall der Zweitsprache
    \def\oex@scndlang{\textcolor{blue}{\csuse{oex@temp#1}}}
    \booltrue{oex@lang@twolanguages}
  }
}
\expandafter\docsvlist\expandafter{\osgexam@lang}
\providecommand{\oex@scndlang}{} % wenn keine Zweitsprache gesetzt ist, wird sie hier leer definiert
% Aus irgendeinem Grund (TODO: warum?) vertragen sich Polyglossias Kommandos nicht mit
% eToolBox'Schleifen-Mechanismus. Daher werden sie dort nicht direkt gerufen,
% sondern über ein Macro.
%\typeout{********* \meaning\oex@pg@settings}
%\oex@pg@settings

% Zur Unterstützung von Mehrsprachigkeit gibt es mehrere Befehle, die auch direkt von Prüfungsautoren eingesetzt werden
% können.
% * \deen{<deutscher Text>}{<englischer Text>} gibt den Text der Erstspraeche aus. Falls die Zweitsprache definiert ist, 
%    wird der entsprechende Text anschließend in einer neuen Zeile und in einer Alternativfarbe ausgegeben.
% * \sdeen{<deutscher Text>}{<englischer Text>}: wie \ldeen, nur wird statt einer neuen Zeile ein Schrägstrich ("/") gesetzt
% * \ldeen{<deutscher Text>}{<englischer Text>}: gibt *nur* den Text der Erstsprache aus.
\newrobustcmd{\deen}[2]{\def\oex@tempde{\booltrue{oex@active@de}\textgerman{#1}\boolfalse{oex@active@de}}%
  \def\oex@tempen{\booltrue{oex@active@en}\textenglish{#2}\boolfalse{oex@active@en}}%
  \oex@frstlang\ifbool{oex@lang@twolanguages}{\newline\oex@scndlang}{}}
\newrobustcmd*{\sdeen}[2]{\def\oex@tempde{\booltrue{oex@active@de}\textgerman{#1}\boolfalse{oex@active@de}}%
  \def\oex@tempen{\booltrue{oex@active@en}\textenglish{#2}\boolfalse{oex@active@en}}%
  \oex@frstlang\ifbool{oex@lang@twolanguages}{/\oex@scndlang}{}}
\newrobustcmd{\ldeen}[2]{\def\oex@tempde{\booltrue{oex@active@de}\textgerman{#1}\boolfalse{oex@active@de}}%
  \def\oex@tempen{\booltrue{oex@active@en}\textenglish{#2}\boolfalse{oex@active@en}}\oex@frstlang}
% Wie \ldeen, richtet sich aber nicht nach der Erstsprache, sondern kann *innerhalb* der anderen Sprachkommandos
% verwendet werden, gibt also stets den Text in der Sprache des Kontexts aus.
\DeclareRobustCommand{\cdeen}[2]{\ifbool{oex@active@de}{#1}{}\ifbool{oex@active@en}{#2}{}}
 % Nur für Debugging
\iffalse 
%\iftrue 
\ifbool{oex@lang@en}{
  \typeout{*** English is active}
}{
  \typeout{*** English is NOT active}
}
\ifbool{oex@lang@de}{
  \typeout{*** Deutsch ist aktiv}
}{
  \typeout{*** Deutsch ist NOT aktiv}
}%
\fi

%%%%%%%%%%%%%% Titelseite %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\RequirePackage{xspace}
\RequirePackage{tikz}
\newcounter{pointstopass}%
\newcommand*{\insertPointsToPass}{\ifundef{\exam@numpoints}{9999}{\setcounter{pointstopass}{\exam@numpoints}\setcounter{pointstopass}{\numexpr\thepointstopass*\osgexam@passedwith/100\relax}\thepointstopass}}

\renewcommand{\maketitle}{
  \begin{tikzpicture}[overlay]
    % Studentenidentifikation, sollte genau im Sichtfenster eines A4-Umschlags liegen
    \node[align=left, draw=black, text width = 6.9cm, rounded corners,
    xshift=4.2cm, yshift=-3cm, minimum size=3.5cm, minimum width=8.5cm, inner
    sep=0pt] {
      \begin{tabular}[t]{l@{\hspace{2em}}l}
        \texttt{\Huge \studentid}&\ifosgexam@seat
                                   \ldeen{Platz}{Seat}: \seat
                                   \fi\\
        \\
        {\tiny \studentname}&\ifosgexam@group
                                   \ldeen{Gruppe}{Group}: \studentgroup
                                   \fi
        \\
         {\tiny \insertCourseAcronym\xspace (\insertCourseSemester)}
    \\[1em]
    \multicolumn{2}{l}{
    \sffamily{\textcolor{red}{\textbf{\ldeen{Nicht öffnen, warten Sie auf
            Anweisungen!}{Do not open, wait for instructions!}}}}}
      \end{tabular}
    };
    
  
  \end{tikzpicture}
  
  % Punktetabelle
  \begin{tikzpicture}[overlay]
    \node[xshift=8cm, yshift=1.2cm, align=center, text width =
    19cm,rounded corners, minimum size=3cm, ]{
      \color{gray}
      \let\oex@gradetable=\gradetable
      \ifdef{\exam@numbonuspoints}{
        \ifnumcomp{\exam@numbonuspoints}{>}{0}{
          \let\oex@gradetable=\combinedgradetable
          
        }{}
      }{}
      \oex@gradetable[h]
    };
  % Titel
  \node[xshift=12.6cm, yshift=-2.3cm, text width=7.1cm, align=center,font=\huge]{
        {\large \uppercase{\ldeen{Prüfung}{Exam}}}\\
        \ldeen{\expandafter\uppercase\expandafter{\insertCourseName}}{\expandafter\uppercase\expandafter{\insertCourseName}}
      };
  \end{tikzpicture}
  % bei zweisprachigen Prüfungen wird mehr Platz für die Regeln auf der
  % Titelseite benötigt 
  \ifbool{oex@lang@twolanguages}{
    \def\oex@rulespace{22.6cm}
    \enlargethispage{10ex}}{
    \def\oex@rulespace{21cm} 
  }
  % Prüfungsregeln
  \begin{minipage}[t][\oex@rulespace][c]{1.01\textwidth}\vspace*{5cm}
    \ifbool{osgexam@impolite}{\textbf{\sdeen{Regeln}{Rules}:}}{\noindent\deen{Willkommen zur Klausur {\textbf \insertCourseName}! Beachten Sie bitte
        die folgenden Regeln:}{Welcome to the exam on {\textbf \insertCourseName}! Please regard the following rules:}}
    \oex@rules
    \noindent\textbf{\deen{Zum Bestehen der Prüfung müssen Sie mindestens
        \insertPointsToPass\ Punkte erreichen. \ifbool{osgexam@impolite}{}{Viel Erfolg!}}{For passing
        the exam you need at least \insertPointsToPass\ points. \ifbool{osgexam@impolite}{}{We wish
          you success!}}} 
    \vfil
  \end{minipage}
  
  \clearpage
  % Stil für die folgenden Seiten
  \header{\oddeven{Matrikelnr.: \studentid}{\thepage}}{}{\oddeven{\thepage}{\insertCourseAcronym \xspace
      \insertCourseSemesterShort}} % Kopfzeile auf jeder Seite 
  \footer{}{}
  \headrule % Linie unter der Kopfzeile
  \pointsinrightmargin % Der Name sagt alles...
  \shadedsolutions % ...und der auch 
}

%%%%%%%%%%%%%% Regeln für die Prüfung %%%%%%%%%%%%%%%%%%%%%%
% Für die Regeln auf der Titelseite gibt es  (für die OSG) sinnvolle Standards.
% Bei Bedarf können diese aber in der Präambel angepasst werden
\newcounter{oex@fprcnt}
\setcounter{oex@fprcnt}{0}
\directlua{
  oexfrontpagerules={}
}
% Fügt neue Regel hinzu
\newcommand{\addFrontPageRule}[1]{%
    \stepcounter{oex@fprcnt}
    \directlua{
      oexfrontpagerules[\theoex@fprcnt]=\luastringN{#1}
    }
}
% Ersetzt eine Regel. Dabei wird immer von der ursprünglichen Numerierung ausgegangen.
\newcommand{\replaceFrontPageRule}[2]{
    \directlua{
      oexfrontpagerules[#1]=\luastringN{#2}
    }
}
% Löscht eine Regel. Dabei wird immer von der ursprünglichen Numerierung ausgegangen.
\newcommand{\removeFrontPageRule}[1]{
    \directlua{
      oexfrontpagerules[#1]=nil
    }
}
% Gibt die Regeln aus, wird von
\newcommand{\oex@rules}{%
  \begin{itemize}
  \makeatletter
    \directlua{
      for _, v in pairs(oexfrontpagerules) do
      tex.print(\luastringN{\item })
      tex.print(v)
      end
    }
  \makeatother
  \end{itemize}
}
% Standardregeln
\addFrontPageRule{
  \deen{Sie haben zur Beantwortung aller Fragen \osgexam@solutiontime\ Minuten Zeit.
    \ifbool{oex@lang@twolanguages}{Sie können auf Deutsch oder Englisch antworten.}{}}
  {You have \osgexam@solutiontime\ minutes for answering all
    questions. \ifbool{oex@lang@twolanguages}{You can answer in English or
      German.}{}}
}
\addFrontPageRule{
  \deen{Durch Annahme des Aufgabenblattes erklären Sie, dass Sie
    \textbf{gesundheitlich in der Lage} sind, eine Prüfung abzulegen.}{By accepting
    this task sheet you declare that you are \textbf{in a proper health condition} for
    an exam.} 
}
\addFrontPageRule{
  \deen{Bitte stellen Sie Ihre Lösung lesbar und sauber dar. Schreiben Sie
    Ihre Lösungen auf dieses Aufgabenblatt! Außer für Multiple-Choice- und
    Fill-In-Fragen \textbf{muss stets erkennbar sein, wie Sie zum Ergebnis
    gelangen!}}{Please write clear and readable. Write the final results on
    this exam sheet! Except for multiple choice questions and fill in
    questions, \textbf{you must provide the solution way!}}
}
\addFrontPageRule{
  \deen{Erlaubte Hilfsmittel sind Schreibwerkzeuge, ein
  \textbf{nichtprogrammierbarer} Taschenrechner, ein gedrucktes Wörterbuch
  ohne handschriftliche Notizen sowie ein A4-Blatt (2 Seiten) mit handschriftlichen(!) Notizen.}{The only tools to be used are pens, a
  \textbf{non-programmable} calculator, a printed dictionary without
  annotations, and one piece of A4 paper (2 pages) with handwritten(!) notes.}
}
\addFrontPageRule{
  \deen{Elektronische Geräte mit nichtflüchtigem Speicher oder
    Kommunikationsfähigkeiten - egal ob aktiviert oder nicht - sind
    untersagt. Das Vorhandensein solcher Geräte in Ihrer Reichweite kann als
    Betrugsversuch gewertet werden.}{Devices with non-volatile storage or
    communication capabilities (whether enabled or not) are forbidden. The
    presence of such devices in your proximity can be interpreted as a case of
    fraud.} 
}
\addFrontPageRule{
  \deen {Gespräche mit anderen Studenten und der Austausch von schriftlichen
    Notizen sind während der Bearbeitungszeit untersagt und können als
    Betrugsversuch gewertet werden.}{ Talking to other students or exchange of
    written notes during the exam can be interpreted as a case of fraud.} 
}
\addFrontPageRule{
\deen{Wenn Sie eine Frage haben oder die Toilette aufsuchen müssen, melden Sie
  sich bitte und warten auf eine Aufsichtsperson.}{If you have questions or if
  you need to go to the toilet notify a supervisor.} 
}
\addFrontPageRule{
  \deen{Bei unerlaubten Handlungen werden die Prüfungunterlagen \textbf{aller
    involvierten Studierenden} eingezogen und ihnen die Note 5 erteilt.}{In
    case of a fraud, \textbf{all participating students} will fail the exam.} 
}
%%%%%%%%%%%%%% Formatierung %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\qformat{\textbf{\ldeen{Aufgabe}{Question} \ifstreq{\thequestion}{\thequestiontitle}{\thequestion}{\thequestion: \thequestiontitle}}%
  \dotfill (\totalpoints)}
\bonusqformat{\textbf{\ldeen{Aufgabe}{Question} \ifstreq{\thequestion}{\thequestiontitle}{\thequestion}{\thequestion: \thequestiontitle}%
   (Bonus)} \dotfill (+\totalbonuspoints)}
% ToDo: Wiederherstellen des Parsens von gemischt regulären und optionalen Punkten
\qformat{\textbf{\ldeen{Aufgabe}{Question} \ifstreq{\thequestion}{\thequestiontitle}{\thequestion}{\thequestion: \thequestiontitle}}%
  \dotfill (\totalpoints\oex@nbqbonuspoints~\oex@sumpointpoints{\totalpoints}{\totalbonuspoints})}
%\bonusqformat{\textbf{\ldeen{Aufgabe}{Question} \ifstreq{\thequestion}{\thequestiontitle}{\thequestion}{\thequestion: \thequestiontitle}%
%  (Bonus)}\def\@points{\totalbonuspoints} \dotfill (+\@points~\bonuspoints)}
% pointpoints wird für Subpunkte (am Rand) genutzt
\pointpoints{\ldeen{Punkt}{point}}{\ldeen{Punkte}{points}}
\bonuspointpoints{\ldeen{Punkt}{point}}{\ldeen{Punkte}{points}}
% Statt nachgesetzem "Bonus" wird einfach ein Pluszeichen vorgesetzt
\bonuspointformat{(+\@points)}
% Bonuspunkte für Nicht-Bonusfragen (z.B. aber mit Bonusparts)
\def\oex@nbqbonuspoints{%
  \ifcsdef{bonuspointsofq@\romannumeral\value{question}}{%
    \ifnum\csuse{bonuspointsofq@\romannumeral\value{question}}>0\relax
    +\csuse{bonuspointsofq@\romannumeral\value{question}}%
    \fi
  }{}%
}
% Damit die Gammatik auch bei z.B. 1+1 Punkten korrekt ist (und ich auf Kriegsfuß mit TeX-Mathe stehe), wird die
% Gesamtsumme an Punkten in Lua überprüft
\ldeen{
  \luadirect{
    oexpointpoints={
      ['s']='Punkt',
      ['p']='Punkte'
    }
  }
}{
  \luadirect{
    oexpointpoints={
      ['s']='point',
      ['p']='points'
    }
  }
}
\DeclareRobustCommand{\oex@sumpointpoints}[2]{%
  \if\relax\detokenize\expandafter{\romannumeral-0#1}\relax%
    \if\relax\detokenize\expandafter{\romannumeral-0#2}\relax%
      \luadirect{
        local p=tonumber(\luastring{#1})
        local b=tonumber(\luastring{#2})
        if b == nil then b = 0 end
        if p == nil then p = 0 end
        if p+b>1 then
          tex.print(oexpointpoints['p']) 
        else
          tex.print(oexpointpoints['s']) 
        end
        }%
  \fi\fi%
}
% Multiple Choice
\RequirePackage{amssymb}
\checkboxchar{$\Box$}
\checkedchar{$\boxtimes$}

%%%%%%%%%%%%%% Präamble  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Name des Kurses und optional des Kursakronyms. Innerhalb der Argumente kann \cdeen benutzt werden.
\DeclareRobustCommand*{\course}[2][]{%
  \ifstrempty{#1}{\newcommand*{\insertCourseAcronym}{#2}}{\newcommand*{\insertCourseAcronym}{#1}}
  \newcommand*{\insertCourseName}{#2}
}
%% Bezeichnung des Semesters und optional Kurzform
\DeclareRobustCommand*{\term}[2][]{
  \ifstrempty{#1}{\newcommand*{\insertCourseSemesterShort}{#2}}{\newcommand*{\insertCourseSemesterShort}{#1}}
  \newcommand*{\insertCourseSemester}{#2}
}
%% Lösungszeit in Minuten. Standardwert ist 90
\DeclareRobustCommand*{\solutionTime}[1]{\pgfkeys{/osgexam/solutiontime=#1}}
%% Gruppe per Hand
\DeclareRobustCommand*{\setGroup}[1]{\def\studentgroup{#1}}

%% Zusätzliche Punkte, die als Bonuspunkte in der Punkttabelle erscheinen.
%   Optional kann ein Titel eingegeben werden.
%   Mit Hilfe dieser Zusatzpunkte können externe Leistungen (z.B. Labor oder Belegaufgaben) berücksichtigt werden
\newcommand*{\addextrapoints}[2][]{ 
  \AtEndEnvironment{questions}{
    \addtocounter{numquestions}{1}
    \immediate\write\@mainaux
    {\string\gdef\string\bonuspointsofq@\romannumeral\thenumquestions{#2}^^J
      \string\gdef\string\pointsofq@\romannumeral\thenumquestions{0}^^J
      \string\newlabel{question@\thenumquestions}{{#1}{}}
    }%
  }%
}

\AfterEndPreamble{
%  \RequirePackage[utf8]{luainputenc}
  \maketitle
}
%%%%%%%%%%%%%% Gruppen %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\NewDocumentCommand{\oex@addgroup}{m}{\listgadd{\oex@groupslist}{#1}}
\NewDocumentCommand{\DeclareGroups}{> { \SplitList {,} } m}{
    \ProcessList {#1}{\oex@addgroup}
}
\NewDocumentEnvironment{onlygroup}{> { \SplitList {,} } m  +b}{%
    \gdef\oex@groupslist{}%
    \ProcessList {#1}{\oex@addgroup}%
    \xifinlist{\studentgroup}{\oex@groupslist}{#2}{}%
}{}

%%%%%%%%%%%%%% Watermark %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\ifprintanswers
\RequirePackage[
  color=black,
  opacity=0.1,
  contents={Foo}
  ]{background}
  \backgroundsetup{contents=\sffamily\bfseries\ldeen{Musterlösung}{Standard Solution}}
\fi

%%%%%%%%%%%%%% Convenience %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\newcommand{\oex@xchecknextarg}{%
  \@ifnextchar\bgroup{\osx@consumnextarg}{\oex@process@xdeen}
}
\newcommand{\osx@consumnextarg}[1]{%
  \luadirect{
    oex_deenargcnt=oex_deenargcnt+1
    oex_deenargs[oex_deenargcnt]=\luastringN{#1}
  }%
  \@ifnextchar\bgroup{\osx@consumnextarg}{\oex@process@xdeen} 
}
\def\oex@process@xdeen{
  \luadirect{
    for i=1, oex_deenargcnt do
      oex_deenpat='@'.. tostring(i)
      oex_deende , _ = string.gsub(oex_deende, oex_deenpat, oex_deenargs[i])
      oex_deenen , _ = string.gsub(oex_deenen, oex_deenpat, oex_deenargs[i])
    end
    tex.print('\string\\deen{'..oex_deende..'}{'..oex_deenen..'}')
  }
}
\newcommand{\xdeen}[2]{
  \luadirect{
    oex_deenargs={}
    oex_deenargcnt=0
    oex_deende=\luastringN{#1}
    oex_deenen=\luastringN{#2}
  }
  \oex@xchecknextarg
}
