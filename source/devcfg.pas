{
	This file is part of Dev-C++
	Copyright (c) 2004 Bloodshed Software

	Dev-C++ is free software; you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation; either version 2 of the License, or
	(at your option) any later version.

	Dev-C++ is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with Dev-C++; if not, write to the Free Software
	Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
}

unit devcfg;

interface

uses
{$IFDEF WIN32}
  Dialogs, Windows, Classes, Graphics, SynEdit, CFGData, CFGTypes, IniFiles, prjtypes, Math;
{$ENDIF}
{$IFDEF LINUX}
  QDialogs, Classes, QGraphics, QSynEdit, CFGData, CFGTypes, IniFiles, Math, prjtypes;
{$ENDIF}

const
	BoolValYesNo: array[boolean] of string = ('No', 'Yes');
	BoolVal10: array[0..27] of string = ('0', '1', 'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h',
                                         'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r',
                                         's', 't', 'u', 'v', 'w', 'x', 'y', 'z');

type
	// the comments are an example of the record
	PCompilerOption = ^TCompilerOption;
	TCompilerOption = packed record
		optName: string; // "Generate debugging info"
		optIsGroup: boolean; // False
		optIsC: boolean;
		optIsCpp: boolean; // True (C++ option?) - can be both C and C++ option...
		optIsLinker: boolean; // Is it a linker param
		optValue: Integer; // True
		optSetting: string; // "-g3"
		optSection: string; // "Linker options"
		optExcludeFromTypes: TProjTypeSet; // [dptGUI] (don't show option if project is of type dptGUI)
		optChoices : TStringList; // replaces "Yes/No" standard choices (max 30 different choices)
	end;

	// compiler-set configuration
	TdevCompilerSet = class(TCFGOptions)
	private
		// Sets
		fSets: TStrings;

		// Exe Directories
		fgccName : string;
		fgppName : string;
		fmakeName : string;
		fgdbName : string;
		fwindresName : string;
		fdllwrapName : string;
		fgprofName : string;

		// Folders
		fBinDir : string;
		fCDir : string;
		fCppDir : string;
		fLibDir : string;

		// User Parameters
		fCompAdd : boolean;
		fLinkAdd : boolean;
		fCompOpt : string;
		flinkOpt : string;

		fDelay : integer;
		fFastDep : boolean;

		// All options
		fOptions : string;

		procedure WriteSets;
		procedure UpdateSets;
	public
		constructor Create;
		destructor Destroy; override;
		procedure SettoDefaults; override;
		procedure SaveSettings; override;
		procedure LoadSettings; override;
		procedure SaveSet(Index: integer);
		procedure LoadSet(Index: integer);
		procedure AssignToCompiler;
		property Name;
		function SetName(Index: integer): string;
		property Sets: TStrings read fSets write fSets;
	published
		property gccName: string read fgccName write fgccName;
		property gppName: string read fgppName write fgppName;
		property makeName: string read fmakeName write fmakeName;
		property gdbName: string read fgdbName write fgdbName;
		property windresName: string read fwindresName write fwindresName;
		property dllwrapName: string read fdllwrapName write fdllwrapName;
		property gprofName: string read fgprofName write fgprofName;

		property BinDir: string read fBinDir write fBinDir;
		property CDir: string read fCDir write fCDir;
		property CppDir: string read fCppDir write fCppDir;
		property LibDir: string read fLibDir write fLibDir;

		property OptionsStr: string read fOptions write fOptions;

		property AddtoComp: boolean read fCompAdd write fCompAdd;
		property AddtoLink: boolean read fLinkAdd write fLinkAdd;
		property CompOpts: string read fCompOpt write fCompOpt;
		property LinkOpts: string read fLinkOpt write fLinkOpt;

		property Delay: integer read fDelay write fDelay;
		property FastDep: boolean read fFastDep write fFastDep;
	end;

	// Each compiler is contained in one class
	TdevCompiler = class(TCFGOptions)
	private
		// The set to load
		fCompilerSet: integer;

		// Non-set options
		fUseParams: boolean;        // Use fparams when running prog
		fIntermediate: string;      // directory for mid-compile files -- if needed
		fOutputDir: string;         // directory to place compiled files
		fRunParams: string;         // params to send on execution

		// Exe Directories
		fgccName : string;
		fgppName : string;
		fmakeName : string;
		fgdbName : string;
		fwindresName : string;
		fdllwrapName : string;
		fgprofName : string;

		// User Parameters
		fCompAdd : boolean;
		fLinkAdd : boolean;
		fCompOpt : string;
		flinkOpt : string;

		// All options
		fOptions: TList;
		fDelay : integer;
		fFastDep : boolean;

		// Debugger
		fModified: boolean; // has options been changed since last compile

		procedure SetCompilerSet(const Value: integer);
		function GetOptions(Index: integer): TCompilerOption;
		procedure SetOptions(Index: integer; const Value: TCompilerOption);
		function GetOptionStr: string;
		procedure SetOptionStr(const Value: string);
	protected
		procedure AddDefaultOptions;
	public
		constructor Create;
		destructor Destroy; override;
		procedure SettoDefaults; override;
		procedure SaveSettings; override;
		procedure LoadSettings; override;
		property Name;
		property Modified: boolean read fModified write fModified;
		procedure AddOption(_Name: string; _IsGroup, _IsC, _IsCpp, IsLinker: boolean; _Value: integer; _Setting, _Section: string; ExcludeFromTypes: TProjTypeSet; Choices: TStringList);
		function OptionsCount: integer;
		procedure ClearOptions;
		procedure DeleteOption(Index: integer);
		property Options[Index: integer]: TCompilerOption read GetOptions write SetOptions;
		property OptionStr: string read GetOptionStr write SetOptionStr;
		function FindOption(Setting: string; var opt: TCompilerOption; var Index: integer): boolean; // returns the option with setting=<Setting>
		procedure ChangeOptionsLang;
		function ConvertCharToValue(c : char) : integer;
	published
		property RunParams: string read fRunParams write fRunParams;
		property UseExecParams: boolean read fUseParams write fUseParams;
		property Delay: integer read fDelay write fDelay;
		property FastDep: boolean read fFastDep write fFastDep;

		property gccName: string read fgccName write fgccName;
		property gppName: string read fgppName write fgppName;
		property gdbName: string read fgdbName write fgdbName;
		property makeName: string read fmakeName write fmakeName;
		property windresName: string read fwindresName write fwindresName;
		property dllwrapName: string read fdllwrapName write fdllwrapName;
		property gprofName: string read fgprofName write fgprofName;

		property AddtoComp: boolean read fCompAdd write fCompAdd;
		property AddtoLink: boolean read fLinkAdd write fLinkAdd;
		property CompOpts: string read fCompOpt write fCompOpt;
		property LinkOpts: string read fLinkOpt write fLinkOpt;

		property CompilerSet: integer read fCompilerSet write SetCompilerSet;
	end;

 // code-completion window size and other config
 TdevCodeCompletion = class(TCFGOptions)
 private
   fWidth: integer;
   fHeight: integer;
   fDelay: integer;
   fBackColor: integer;
   fEnabled: boolean;
   fUseCacheFiles: boolean;
   fCacheFiles: TStrings;
   procedure SetDelay(Value: integer);
 public
   constructor Create;
   destructor Destroy; override;
   procedure SettoDefaults; override;
   procedure SaveSettings; override;
   procedure LoadSettings; override;
   property Name;
 published
   property Width: integer read fWidth write fWidth;
   property Height: integer read fHeight write fHeight;
   property Delay: integer read fDelay write SetDelay;
   property BackColor: integer read fBackColor write fBackColor;
   property Enabled: boolean read fEnabled write fEnabled;
   property UseCacheFiles: boolean read fUseCacheFiles write fUseCacheFiles;
   property CacheFiles: TStrings read fCacheFiles write fCacheFiles;
 end;

 // class-browsing view style
 TdevClassBrowsing = class(TCFGOptions)
 private
   fCBViewStyle: integer;
   fEnabled: boolean;
   fParseLocalHeaders: boolean;
   fParseGlobalHeaders: boolean;
   fShowFilter: integer; // 0 - show all, 1 - show project, 2 - show current
   fUseColors: boolean;
   fShowInheritedMembers: boolean;
 public
   constructor Create;
   procedure SettoDefaults; override;
   procedure SaveSettings; override;
   procedure LoadSettings; override;
   property Name;
 published
   property Enabled: boolean read fEnabled write fEnabled;
   property ViewStyle: integer read fCBViewStyle write fCBViewStyle;
   property ParseLocalHeaders: boolean read fParseLocalHeaders write fParseLocalHeaders;
   property ParseGlobalHeaders: boolean read fParseGlobalHeaders write fParseGlobalHeaders;
   property ShowFilter: integer read fShowFilter write fShowFilter;
   property UseColors: boolean read fUseColors write fUseColors;
   property ShowInheritedMembers: boolean read fShowInheritedMembers write fShowInheritedMembers;
 end;

 // CVS handling module
 TdevCVSHandler = class(TCFGOptions)
 private
   fRepositories: TStrings;
   fExecutable: string;
   fCompression: byte;
   fUseSSH: boolean;
 public
   constructor Create;
   destructor Destroy; override;
   procedure SettoDefaults; override;
   procedure SaveSettings; override;
   procedure LoadSettings; override;
   property Name;
 published
   property Repositories: TStrings read fRepositories write fRepositories;
   property Executable: string read fExecutable write fExecutable;
   property Compression: byte read fCompression write fCompression;
   property UseSSH: boolean read fUseSSH write fUseSSH;
 end;

 TdevExternalPrograms = class(TCFGOptions)
 private
   fDummy: boolean;
   fPrograms: TStrings;
   function GetProgramName(Index: integer): string;
 public
   constructor Create;
   destructor Destroy; override;
   procedure SaveSettings; override;
   procedure LoadSettings; override;
   procedure SetToDefaults; override;
   property Name;
   property ProgramName[Index: integer]: string read GetProgramName;
   function AssignedProgram(ext: string): integer;
   function AddProgram(ext, prog: string): integer;
 published
   property Dummy: boolean read fDummy write fDummy;
   property Programs: TStrings read fPrograms write fPrograms;
 end;

 // global directories
 TdevDirs = class(TCFGOptions)
  private
   fThemes: string;            // Themes Directory
   fIcons: string;             // Icon Library
   fHelp: string;              // Help
   fLang: string;              // Language
   fTemp: string;              // Templates
   fDefault: string;           // user defined default
   fExec: string;              // dev-c start
   fConfig : string;           // config files directory
   fBinDir: string;            // compiler location
   fCDir: string;              // c includes
   fCppDir: string;            // c++ includes
   fLibDir: string;            // Libraries
   fOldPath: string;           // Enviroment Path at program start
  public
   constructor Create;
   procedure SettoDefaults; override;
   procedure SaveSettings; override;
   procedure LoadSettings; override;
   property Name;
   property OriginalPath: string read fOldPath write fOldPath;
  published
   property Exec: string read fExec write fExec;
   property Config: string read fConfig write fConfig;
   property Bins: string read fBinDir write fBinDir;
   property Default: string read fDefault write fDefault;
   property C: string read fCDir write fCDir;
   property Cpp: string read fCppDir write fCppDir;
   property Help: string read fHelp write fHelp;
   property Icons: string read fIcons write fIcons;
   property Lang: string read fLang write fLang;
   property Lib: string read fLibDir write fLibDir;
   property Templates: string read fTemp write fTemp;
   property Themes: string read fThemes write fThemes;
  end;

 // editor options -- syntax, synedit options, etc...
 TdevEditor = class(TCFGOptions)
  private
   fUseSyn: boolean;           // use syntax highlighting
   fSynExt: string;            // semi-colon seperated list of highlight ext's
   fFont: TFont;               // Editor Font
   fGutterFont: TFont;         // Gutter font
   fInsertCaret: integer;      // Editor insert caret
   fOverwriteCaret: integer;   // Editor overwrite caret
   fTabSize: integer;          // Editor Tab Size
   fGutterSize: integer;       // Width of Left margin gutter
   fMarginSize: integer;       // Width of right margin

   fCustomGutter: boolean;     // Use Selected Gutter font
   fGutterAuto: boolean;       // Gutter Auto Sizes
   fShowGutter: boolean;       // Show Left gutter in editor
   fLineNumbers: boolean;      // Show Line Numbers
   fLeadZero: boolean;         // Show leading zero's in line nums
   fFirstisZero: boolean;      // First line is zero

   fMarginVis: boolean;        // Toggle right margin line

   fShowScrollHint: boolean;   // Show line number when scrolling
   fShowScrollbars: boolean;   // Show Scroll bars
   fHalfPage: boolean;         // PgUp/PgDn move half a page

   fPastEOF: boolean;          // Cursor moves past end of file
   fPastEOL: boolean;          // Cursor moves past end of lines
   fdblLine: boolean;          // Double Click selects a line
   fFindText: boolean;         // Text at cursor defaults in find dialog
   fEHomeKey: boolean;         // Home key like visual studio
   fGroupUndo: boolean;        // treat same undo's as single undo
   fInsDropFiles: boolean;     // Insert files when drag/dropped else open
   fInsertMode: boolean;       // Editor defaults to insert mode
   fAutoIndent: boolean;       // Auto-indent code lines
   fSmartTabs: boolean;        // Tab to next no whitespace char
   fSpecialChar: boolean;      // special line characters visible
   fTabtoSpaces: boolean;      // convert tabs to spaces
   fShowFunctionTip: boolean;  // show function tip
   fMarginColor: TColor;       // Color of right margin
   fSyntax: TStrings;          // Holds attributes settings
   fDefaultIntoPrj: boolean;   // Insert Default Source Code into "empty" project
   fParserHints: boolean;      // Show parser's hint for the word under the cursor
   fMatch : boolean;           // Highlight matching parenthesis
   fHighCurrLine: boolean;     // Highlight current line
   fHighColor: TColor;         // Color of current line when highlighted

   // Autosave
   fEnableAutoSave : boolean;
   fInterval : integer;
   fSaveType : integer;

   // Symbol completion
   fBraceComplete : boolean;
   fParentheseComplete : boolean;
   fIncludeComplete : boolean;
   fCommentComplete : boolean;
   fArrayComplete : boolean;
   fCompleteSymbols : boolean;
  public
   constructor Create;
   destructor Destroy; override;
   procedure SettoDefaults; override;
   procedure SaveSettings; override;
   procedure LoadSettings; override;
   procedure AssignEditor(Editor: TSynEdit);
   property Name;
  published
   //Editor props
   property AutoIndent: boolean read fAutoIndent write fAutoIndent;
   property InsertMode: boolean read fInsertMode write fInsertMode;
   property TabToSpaces: boolean read fTabToSpaces write fTabToSpaces;
   property SmartTabs: boolean read fSmartTabs write fSmartTabs;
   property GroupUndo: boolean read fGroupUndo write fGroupUndo;
   property EHomeKey: boolean read fEHomeKey write fEHomeKey;
   property PastEOF: boolean read fPastEOF write fPastEOF;
   property PastEOL: boolean read fPastEOL write fPastEOL;
   property DblClkLine: boolean read fdblLine write fdblLine;
   property FindText: boolean read fFindText write fFindText;
   property Scrollbars: boolean read fShowScrollbars write fShowScrollbars;
   property HalfPageScroll: boolean read fHalfPage write fHalfPage;
   property ScrollHint: boolean read fShowScrollHint write fShowScrollHint;
   property SpecialChars: boolean read fSpecialChar write fSpecialChar;
   property ShowFunctionTip: boolean read fShowFunctionTip write fShowFunctionTip;

   property TabSize: integer read fTabSize write fTabSize;
   property MarginVis: boolean read fMarginVis write fMarginVis;
   property MarginSize: integer read fMarginSize write fMarginSize;
   property MarginColor: TColor read fMarginColor write fMarginColor;
   property InsertCaret: integer read fInsertCaret write fInsertCaret;
   property OverwriteCaret: integer read fOverwriteCaret write fOverwriteCaret;
   property InsDropFiles: boolean read fInsDropFiles write fInsDropFiles;
   property Font: TFont read fFont write fFont;

   // Gutter options
   property GutterVis: boolean read fShowGutter write fShowGutter;
   property GutterAuto: boolean read fGutterAuto write fGutterAuto;
   property LineNumbers: boolean read fLineNumbers write fLineNumbers;
   property LeadZero: boolean read fLeadZero write fLeadZero;
   property FirstLineZero: boolean read fFirstisZero write fFirstisZero;
   property Gutterfnt: boolean read fCustomGutter write fCustomGutter;
   property GutterSize: integer read fGutterSize write fGutterSize;
   property Gutterfont: TFont read fGutterfont write fGutterFont;

   // syntax
   property UseSyntax: boolean read fUseSyn write fUseSyn;
   property SyntaxExt: string read fSynExt write fSynExt;
   property Syntax: TStrings read fSyntax write fSyntax;

   // other
   property DefaulttoPrj: boolean read fDefaultIntoPrj write fDefaultIntoPrj;
   property ParserHints: boolean read fParserHints write fParserHints;
   property Match: boolean read fMatch write fMatch;
   property HighCurrLine: boolean read fHighCurrLine write fHighCurrLine;
   property HighColor: TColor read fHighColor write fHighColor;

   // Autosave
   property EnableAutoSave: boolean read fEnableAutoSave write fEnableAutoSave;
   property Interval: integer read fInterval write fInterval;
   property SaveType: integer read fSaveType write fSaveType;

   // Brace completion
   property BraceComplete: boolean read fBraceComplete write fBraceComplete;
   property ParentheseComplete: boolean read fParentheseComplete write fParentheseComplete;
   property IncludeComplete: boolean read fIncludeComplete write fIncludeComplete;
   property CommentComplete: boolean read fCommentComplete write fCommentComplete;
   property ArrayComplete: boolean read fArrayComplete write fArrayComplete;
   property CompleteSymbols: boolean read fCompleteSymbols write fCompleteSymbols;
 end;

 // master option object -- contains program globals
 TdevData = class(TConfigData)
  private
   fVersion: string;                 // The configuration file's version
   fLang: string;                    // Language file
   fTheme: string;                   // Theme file
   fFindCols: string;                // Find Column widths (comma sep)
   fCompCols: string;                // Compiler Column Widths (comma sep)
   fMsgTabs: integer;                // Editor Tabs
   fMinOnRun: boolean;               // Minimize IDE on run
   fMRUMax: integer;                 // Max number of files in history list
   fBackup: boolean;                 // Create backup files
   fAutoOpen: integer;               // Auto Open Project Files Style
   fShowProject: boolean;            // Show the project explorer
   fProjectWidth: integer;
   fClassView: boolean;              // if true, shows the class view, else shows the file view
   fOutput: boolean;                 // show compiler message window
   fOutputOnNeed: boolean;           // show compiler messages only when problem
   fOutputHeight: integer;           // the height of the output window
   fStatusbar: boolean;              // Statusbar Visible
   fFullScr: boolean;                // IDE is Full screen
   fShowBars: boolean;               // Show toolbars in FullScreen mode
   fMultiLineTab: boolean;           // Show multiline tabs
   fDefCpp: boolean;                 // Default to C++ project (compile with g++)
   fFirst: boolean;                  // first run of dev-c
   fSplash: string;                  // user selected splash screen
   fWinPlace: TWindowPlacement;      // Main forms size, state and position.
   fdblFiles: boolean;               // double click opens files out of project manager
   fLangChange: boolean;             // flag for language change
   fthemeChange: boolean;            // did the theme change?
   fNoSplashScreen : boolean;        // disable splash screen
   fInterfaceFont : string;
   fInterfaceFontSize : integer;
   fConsolePause : boolean;

   fToolbarMain: boolean;            // These ones follow the enable/x-offset/y-offset patern
   fToolbarMainX: integer;
   fToolbarMainY: integer;
   fToolbarEdit: boolean;
   fToolbarEditX: integer;
   fToolbarEditY: integer;
   fToolbarCompile: boolean;
   fToolbarCompileX: integer;
   fToolbarCompileY: integer;
   fToolbarProject: boolean;
   fToolbarProjectX: integer;
   fToolbarProjectY: integer;
   fToolbarSpecials: boolean;
   fToolbarSpecialsX: integer;
   fToolbarSpecialsY: integer;
   fToolbarSearch: boolean;
   fToolbarSearchX: integer;
   fToolbarSearchY: integer;
   fToolbarClasses: boolean;
   fToolbarClassesX: integer;
   fToolbarClassesY: integer;

		// file associations (see FileAssocs.pas)
		fAssociateCpp: boolean;
		fAssociateC: boolean;
		fAssociateHpp: boolean;
		fAssociateH: boolean;
		fAssociateDev: boolean;
		fAssociateRc: boolean;
		fAssociateTemplate: boolean;

		// More misc stuff
		fShowTipsOnStart: boolean;
		fLastTip: integer;
		fFileDate : integer;              // Dev-C++ File Date for checking old configurations
		fShowProgress : boolean;          // Show progress window during compile
		fAutoCloseProgress : boolean;     // Auto close progress bar window after compile

		// Printer
		fPrintColors : boolean;           // print colors
		fPrintHighlight : boolean;
		fPrintWordWrap : boolean;
		fPrintLineNumbers : boolean;
		fPrintLineNumbersMargins : boolean;

		// Debug variable browser
		fWatchHint : boolean;             // watch variable under mouse
		fWatchError : boolean;            // report watch errors

  public
   constructor Create(aOwner: TComponent); override;
   destructor Destroy; override;
   procedure SettoDefaults; override;
   procedure SaveConfigData; override;
   procedure ReadConfigData; override;

   class function DevData: TDevData;
   property WindowPlacement: TWindowPlacement read fWinPlace write fWinPlace;
   property LangChange: boolean read fLangChange write fLangChange;
   property ThemeChange: boolean read fThemeChange write fThemeChange;
  published
   property Version: string read fVersion write fVersion;
   property Language: string read fLang write fLang;
   property Theme: string read fTheme write fTheme;
   property First: boolean read fFirst write fFirst;
   property Splash: string read fSplash write fSplash;
   property MRUMax: integer read fMRUMax write fMRUMax;
   property DblFiles: boolean read fDblFiles write fDblFiles;
   property NoSplashScreen: boolean read fNoSplashScreen write fNoSplashScreen;

   //Execution
   property MinOnRun: boolean read fMinOnRun write fMinOnRun;
   property ConsolePause: boolean read fConsolePause write fConsolePause;


   property BackUps: boolean read fBackup write fBackup;
   property AutoOpen: integer read fAutoOpen write fAutoOpen;

   //Windows
   property MsgTabs: integer read fMsgTabs write fMsgTabs;
   property InterfaceFont: string read fInterfaceFont write fInterfaceFont;
   property InterfaceFontSize: integer read fInterfaceFontSize write fInterfaceFontSize;

   property ShowBars: boolean read fShowbars write fShowbars;
   property MultiLineTab: boolean read fMultiLineTab write fMultiLineTab;

   //Running Status Options
   property DefCpp: boolean read fDefCpp write fDefCpp;
   property ShowOutput: boolean read fOutput write fOutput;
   property OutputOnNeed: boolean read fOutputOnNeed write fOutputOnNeed;
   property OutputHeight: integer read fOutputHeight write fOutputHeight;
   property ProjectView: boolean read fShowProject write fShowProject;
   property ClassView: boolean read fClassView write fClassView;
   property ProjectWidth: integer read fProjectWidth write fProjectWidth;
   property Statusbar: boolean read fStatusbar write fStatusbar;
   property FullScreen: boolean read fFullScr write fFullScr;
   property FindCols: string read fFindCols write fFindCols;
   property CompCols: string read fCompCols write fCompCols;

   //Toolbars
   property ToolbarMain: boolean read fToolbarMain write fToolbarMain;
   property ToolbarMainX: integer read fToolbarMainX write fToolbarMainX;
   property ToolbarMainY: integer read fToolbarMainY write fToolbarMainY;
   property ToolbarEdit: boolean read fToolbarEdit write fToolbarEdit;
   property ToolbarEditX: integer read fToolbarEditX write fToolbarEditX;
   property ToolbarEditY: integer read fToolbarEditY write fToolbarEditY;
   property ToolbarCompile: boolean read fToolbarCompile write fToolbarCompile;
   property ToolbarCompileX: integer read fToolbarCompileX write fToolbarCompileX;
   property ToolbarCompileY: integer read fToolbarCompileY write fToolbarCompileY;
   property ToolbarProject: boolean read fToolbarProject write fToolbarProject;
   property ToolbarProjectX: integer read fToolbarProjectX write fToolbarProjectX;
   property ToolbarProjectY: integer read fToolbarProjectY write fToolbarProjectY;
   property ToolbarSpecials: boolean read fToolbarSpecials write fToolbarSpecials;
   property ToolbarSpecialsX: integer read fToolbarSpecialsX write fToolbarSpecialsX;
   property ToolbarSpecialsY: integer read fToolbarSpecialsY write fToolbarSpecialsY;
   property ToolbarSearch: boolean read fToolbarSearch write fToolbarSearch;
   property ToolbarSearchX: integer read fToolbarSearchX write fToolbarSearchX;
   property ToolbarSearchY: integer read fToolbarSearchY write fToolbarSearchY;
   property ToolbarClasses: boolean read fToolbarClasses write fToolbarClasses;
   property ToolbarClassesX: integer read fToolbarClassesX write fToolbarClassesX;
   property ToolbarClassesY: integer read fToolbarClassesY write fToolbarClassesY;

   // file associations
   property AssociateCpp: boolean read fAssociateCpp write fAssociateCpp;
   property AssociateC: boolean read fAssociateC write fAssociateC;
   property AssociateHpp: boolean read fAssociateHpp write fAssociateHpp;
   property AssociateH: boolean read fAssociateH write fAssociateH;
   property AssociateDev: boolean read fAssociateDev write fAssociateDev;
   property AssociateRc: boolean read fAssociateRc write fAssociateRc;
   property AssociateTemplate: boolean read fAssociateTemplate write fAssociateTemplate;

   // tip of the day
   property ShowTipsOnStart: boolean read fShowTipsOnStart write fShowTipsOnStart;
   property LastTip: integer read fLastTip write fLastTip;

   property FileDate: integer read fFileDate write fFileDate;

   // progress window
   property ShowProgress: boolean read fShowProgress write fShowProgress;
   property AutoCloseProgress: boolean read fAutoCloseProgress write fAutoCloseProgress;

   //  Printer
   property PrintColors: boolean read fPrintColors write fPrintColors;
   property PrintHighlight : boolean read fPrintHighlight write fPrintHighlight;
   property PrintWordWrap : boolean read fPrintWordWrap write fPrintWordWrap;
   property PrintLineNumbers : boolean read fPrintLineNumbers write fPrintLineNumbers;
   property PrintLineNumbersMargins : boolean read fPrintLineNumbersMargins write fPrintLineNumbersMargins;

   // Variable debug browser
   property WatchHint : boolean read fWatchHint write fWatchHint;
   property WatchError : boolean read fWatchError write fWatchError;
 end;

function DevData: TdevData;

procedure InitializeOptions;
procedure SaveOptions;
procedure FinalizeOptions;
procedure ResettoDefaults;
procedure CheckForAltConfigFile(filename: string);
procedure UpdateAltConfigFile;

var
 devCompiler: TdevCompiler = nil;
 devCompilerSet: TDevCompilerSet = nil;
 devDirs: TdevDirs = nil;
 devEditor: TdevEditor = nil;
 devCodeCompletion: TdevCodeCompletion = nil;
 devClassBrowsing: TdevClassBrowsing = nil;
 devCVSHandler: TdevCVSHandler = nil;
 devExternalPrograms: TdevExternalPrograms = nil;

 // Permanent alternate config file (need to be global vars)
 ConfigMode             : (CFG_NORMAL, CFG_PARAM, CFG_USER) = CFG_NORMAL;
 StandardConfigFile     : string;
 UseAltConfigFile       : boolean;
 AltConfigFile          : string;
 DontRecreateSingletons : boolean;

implementation

uses
{$IFDEF WIN32}
  MultiLangSupport, SysUtils, StrUtils, Forms, Controls, version, utils, SynEditMiscClasses,
  FileAssocs;
{$ENDIF}
{$IFDEF LINUX}
  MultiLangSupport, SysUtils, StrUtils, QForms, QControls, version, utils, QSynEditMiscClasses,
  FileAssocs, Types;
{$ENDIF}

function ValidatePaths(dirList: String; var badDirs: String): String;
//checks if directories in provided ; delimited list exist
//returns filtered out dirList with only existing paths
//badDirs returns ; delimited list of non existing dirs
//also remove duplicates and empty entries
var
	strs: TStrings;
	i,j: Integer;
	currdir: String;

	function makeFullPath(dir: String): String;
	begin
		Result := dir;
		//check if it's a full path
{$IFDEF WIN32}
		if Length(dir) > 1 then
			if dir[2] = ':' then
				Exit;
		if Length(dir) > 0 then
			if dir[1] = '\' then
				Exit;
{$ENDIF}
{$IFDEF LINUX}
		if Length(dir) > 0 then
			if dir[1] = '/' then
				Exit;
{$ENDIF}
		//otherwise just add path
		Result := IncludeTrailingPathDelimiter(ExtractFilePath(Application.ExeName)) + Result;
	end;

begin
  Result := '';
  badDirs := '';

  //needed to confirm relative paths
  currdir := GetCurrentDir;
  SetCurrentDir(ExtractFilePath(Application.ExeName));

  strs := TStringList.Create;
  repeat
    if Pos(';', dirList) = 0 then
      strs.Add(dirList)
    else
    begin
      strs.Add(Copy(dirList, 1, Pos(';', dirList) -1));
      Delete(dirList, 1, Pos(';', dirList));
    end;
  until Pos(';', dirList) = 0;

  //eliminate duplicates
  for i := strs.Count -2 downto 0 do
    for j := strs.Count -1 downto i + 1 do
      if (Trim(strs[j]) = '') or
        ( makeFullPath(Trim(strs[i])) = makeFullPath(Trim(strs[j])) ) then
          strs.Delete(j);

  //check the directories
  for i := strs.Count -1 downto 0 do
  begin
    if DirectoryExists(strs[i]) then
      Result := Result + ';' + strs[i]
    else
      badDirs := badDirs + ';' + strs[i];
  end;

  if Length(Result) > 0 then
    if Result[1] = ';' then
      Delete(Result, 1, 1);
  if Length(badDirs) > 0 then
    if badDirs[1] = ';' then
      Delete(badDirs, 1, 1);

  FreeAndNil(strs);

  SetCurrentDir(currdir);
end;

procedure InitializeOptions;
begin
	if not assigned(devDirs) then
		devDirs:= TdevDirs.Create;

	if not assigned(devCompilerSet) then
		devCompilerSet:= TdevCompilerSet.Create;

	if not assigned(devCompiler) then
		devCompiler:= TdevCompiler.Create;

	if not assigned(devEditor) then
		devEditor:= TdevEditor.Create;

	if not assigned(devCodeCompletion) then
		devCodeCompletion:= TdevCodeCompletion.Create;

	if not assigned(devClassBrowsing) then
		devClassBrowsing:= TdevClassBrowsing.Create;

	if not assigned(devCVSHandler) then
		devCVSHandler:= TdevCVSHandler.Create;

	if not assigned(devExternalPrograms) then
		devExternalPrograms:= TdevExternalPrograms.Create;

	// load the preferred compiler set on first run
	if devCompilerSet.Sets.Count=0 then begin
		if AnsiContainsStr(devDirs.Bins,'MinGW32') then
			devCompilerSet.Sets.Add(DEFCOMPILERSET32)
		else
			devCompilerSet.Sets.Add(DEFCOMPILERSET64);

		// Write the compiler list
		devCompilerSet.WriteSets;

		// Write the compiler itself
		devCompilerSet.SaveSet(0);
	end;

	// Load the default one
	devCompilerSet.LoadSet(devCompiler.CompilerSet);
	devCompilerSet.AssignToCompiler;
end;

procedure SaveOptions;
begin
  devData.SaveConfigData;
  devDirs.SaveSettings;
  devCompiler.SaveSettings;
  // devCompilerSet lets devData do the work
  devEditor.SaveSettings;
  devCodeCompletion.SaveSettings;
  devClassBrowsing.SaveSettings;
  devCVSHandler.SaveSettings;
  devExternalPrograms.SaveSettings;
end;

procedure ResettoDefaults;
begin
  devData.SettoDefaults;
  devDirs.SettoDefaults;
  devCompiler.SettoDefaults;
  devCompilerSet.SettoDefaults;
  devEditor.SettoDefaults;
  devCodeCompletion.SettoDefaults;
  devClassBrowsing.SettoDefaults;
  // CVS has no defaults
  devExternalPrograms.SetToDefaults;
end;

procedure FinalizeOptions;
begin
  //devData.Free
  devDirs.Free;
  devCompiler.Free;
  devCompilerSet.Free;
  devEditor.Free;
  devCodeCompletion.Free;
  devClassBrowsing.Free;
  devCVSHandler.Free;
  devExternalPrograms.Free;
end;

procedure CheckForAltConfigFile(filename: string);
var
    Ini: TIniFile;
begin
  UseAltConfigFile:=false;
  AltConfigFile:='';
  if not FileExists(filename) then
    Exit;
  Ini:=TIniFile.Create(filename);
  try
    UseAltConfigFile:=Ini.ReadBool('Options', 'UseAltConfigFile', false);
    AltConfigFile:=Ini.ReadString('Options', 'AltConfigFile', '');
  finally
    Ini.Free;
  end;
end;

procedure UpdateAltConfigFile;
var
    Ini: TIniFile;
begin
  Ini:=TIniFile.Create(StandardConfigFile);
  try
    Ini.WriteBool('Options', 'UseAltConfigFile', UseAltConfigFile);
    Ini.WriteString('Options', 'AltConfigFile', AltConfigFile);
  finally
    Ini.Free;
  end;
end;

 { TDevData - Singleton pattern }
var
 fdevData: TdevData = nil;
 fExternal: boolean = TRUE;


function devData: TdevData;
begin
	if not assigned(fdevData) and not DontRecreateSingletons then begin
		fExternal:= FALSE;
		try
			fdevData:= TdevData.Create(nil);
		finally
			fExternal:= TRUE;
		end;
	end;
	result:= fDevData;
end;

class function TdevData.devData: TdevData;
begin
  result:= devcfg.devData;
end;
(*
  raises an exception when:
   1 - try to create without call to devdata function
         i.e. opt:= TdevData.Create; -- will raise
   2 - if already created -- should never see
*)

// add strings to lang file
constructor TdevData.Create(aOwner: Tcomponent);
begin
  if assigned(fdevData) then
   raise Exception.Create('Dev Data already created');
  if fExternal then
   raise Exception.Create('Dev Data Externally Created');
  inherited Create(aOwner);
  IgnoreProperties.Add('Style');

  SettoDefaults;
end;

destructor TdevData.Destroy;
begin
  fdevData:= nil;
  inherited;
end;

procedure TdevData.ReadConfigData;
begin
  inherited;
  LoadWindowPlacement('Position', fWinPlace);
end;

procedure TdevData.SaveConfigData;
begin
  inherited;
  SaveWindowPlacement('Position', fWinPlace);
end;

procedure TdevData.SettoDefaults;

  function getAssociation(I: integer): Boolean;
  begin
    Result := CheckFiletype('.' + Associations[I, 0],
      'DevCpp.' + Associations[I, 0],
      Associations[I, 1],
      'open',
      Application.Exename + ' "%1"');
  end;

begin
  fVersion:=''; // this is filled in MainForm.Create()
  fFirst:= TRUE;
  fLang:= DEFAULT_LANG_FILE;
  fFindCols:= '75, 75, 120, 150';
  fCompCols:= '75, 75, 120, 150';
  fMsgTabs:= 0; // Top
  fMRUMax:= 10;
  fMinOnRun:= FALSE;
  fBackup:= FALSE;
  fAutoOpen:= 0;
  fShowProject:= TRUE;
  fClassView:= FALSE;
  fProjectWidth:=161;
  fOutput:= FALSE;
  fOutputOnNeed:= TRUE;
  fOutputHeight:=120;
  fStatusbar:= TRUE;
  fShowBars:= FALSE;
  fMultiLineTab:= TRUE;
  fDefCpp:= TRUE;
  fdblFiles:= FALSE;
  fConsolePause:=TRUE;

	fToolbarMain:=TRUE;
	fToolbarMainX:=11;
	fToolbarMainY:=2;
	fToolbarEdit:=TRUE;
	fToolbarEditX:=173;
	fToolbarEditY:=2;
	fToolbarCompile:=TRUE;
	fToolbarCompileX:=441;
	fToolbarCompileY:=2;
	fToolbarProject:=TRUE;
	fToolbarProjectX:=350;
	fToolbarProjectY:=2;
	fToolbarSpecials:=TRUE;
	fToolbarSpecialsX:=624;
	fToolbarSpecialsY:=2;
	fToolbarSearch:=TRUE;
	fToolbarSearchX:=233;
	fToolbarSearchY:=2;
	fToolbarClasses:=TRUE;
	fToolbarClassesX:=11;
	fToolbarClassesY:=30;

	// Office 2007 / Vista support
	if Screen.Fonts.IndexOf('Segoe UI') <> -1 then begin
		fInterfaceFontSize := 9;
		fInterfaceFont := 'Segoe UI';
	end else begin
		fInterfaceFontSize := 8;
		fInterfaceFont := 'MS Sans Serif';
	end;

  //read associations set by installer as defaults
  fAssociateC := getAssociation(0);
  fAssociateCpp := getAssociation(1);
  fAssociateH := getAssociation(2);
  fAssociateHpp := getAssociation(3);
  fAssociateDev := getAssociation(4);
  fAssociateRc := getAssociation(5);
  fAssociateTemplate := getAssociation(6);

  fShowTipsOnStart:=TRUE;
  fLastTip:=0;
  fFileDate := 0;
  fShowProgress := TRUE;
  fAutoCloseProgress := FALSE;
  fPrintColors := TRUE;
  fPrintHighlight := TRUE;
  fPrintWordWrap := FALSE;
  fPrintLineNumbers := TRUE;
  fPrintLineNumbersMargins := FALSE;
  fWatchHint := TRUE;
  fWatchError := TRUE;
end;

{ TCompilerOpts }

procedure TdevCompiler.AddDefaultOptions;
var
	i : integer;
	sl : TStringList;
begin
	// WARNING: do *not* re-arrange the options. Their values are written to the ini file
	// with the same order. If you change the order here, the next time the configuration
	// is read, it will assign the values to the *wrong* options...
	// Anyway, the tree that displays the options is sorted, so no real reason to re-arrange
	// anything here ;)

	// NOTE: As you see, to indicate sub-groups use the "/" char...
	for i := 0 to fOptions.Count - 1 do begin
		if Assigned(PCompilerOption(fOptions.Items[i]).optChoices) then
			PCompilerOption(fOptions.Items[i]).optChoices.Free;
		Dispose(fOptions.Items[i]);
	end;
	fOptions.Clear;

	AddOption(Lang[ID_COPT_ANSIC],       False, True,  True,  False, 0, '-ansi',                     Lang[ID_COPT_GRP_C],       [],       nil);
	AddOption(Lang[ID_COPT_ERRORLINE],   False, True,  True,  True,  0, '-fmessage-length=0',        Lang[ID_COPT_GRP_C],       [],       nil);
	AddOption(Lang[ID_COPT_TRADITIONAL], False, True,  True,  False, 0, '-traditional-cpp',          Lang[ID_COPT_GRP_C],       [],       nil);
	AddOption(Lang[ID_COPT_ACCESS],      False, True,  True,  False, 0, '-fno-access-control',       Lang[ID_COPT_GRP_CPP],     [],       nil);
	AddOption(Lang[ID_COPT_DOLLAR],      False, True,  True,  False, 0, '-fdollar-in-identifiers',   Lang[ID_COPT_GRP_CPP],     [],       nil);
	AddOption(Lang[ID_COPT_HEURISTICS],  False, True,  True,  False, 0, '-fsave-memoized',           Lang[ID_COPT_GRP_CPP],     [],       nil);
	AddOption(Lang[ID_COPT_EXCEPT],      False, True,  True,  False, 0, '-fexceptions',              Lang[ID_COPT_GRP_CODEGEN], [],       nil);
	AddOption(Lang[ID_COPT_DBLFLOAT],    False, True,  True,  False, 0, '-fshort-double',            Lang[ID_COPT_GRP_CODEGEN], [],       nil);
	AddOption(Lang[ID_COPT_MEM],         False, True,  True,  False, 0, '-fverbose-asm',             Lang[ID_COPT_GRP_CODEGEN], [],       nil);
	AddOption(Lang[ID_COPT_WARNING],     False, True,  True,  False, 0, '-w',                        Lang[ID_COPT_GRP_WARN],    [],       nil);
	AddOption(Lang[ID_COPT_WARNINGPLUS], False, True,  True,  False, 0, '-Wall',                     Lang[ID_COPT_GRP_WARN],    [],       nil);
	AddOption(Lang[ID_COPT_WARNINGEX],   False, True,  True,  False, 0, '-Wextra',                   Lang[ID_COPT_GRP_WARN],    [],       nil);
	AddOption(Lang[ID_COPT_ISOCONFORM],  False, True,  True,  False, 0, '-pedantic',                 Lang[ID_COPT_GRP_WARN],    [],       nil);
	AddOption(Lang[ID_COPT_SYNTAXONLY],  False, True,  True,  False, 0, '-fsyntax-only',             Lang[ID_COPT_GRP_WARN],    [],       nil);
	AddOption(Lang[ID_COPT_TREATASERROR],False, True,  True,  False, 0, '-Werror',                   Lang[ID_COPT_GRP_WARN],    [],       nil);
	AddOption(Lang[ID_COPT_FAILONFIRST], False, True,  True,  False, 0, '-Wfatal-errors',            Lang[ID_COPT_GRP_WARN],    [],       nil);
	AddOption(Lang[ID_COPT_PROFILE],     False, True,  True,  False, 0, '-pg',                       Lang[ID_COPT_PROFILING],   [],       nil);
	AddOption(Lang[ID_COPT_OBJC],        False, False, False, True,  0, '-lobjc',                    Lang[ID_COPT_LINKERTAB],   [],       nil);
	AddOption(Lang[ID_COPT_DEBUG],       False, True,  True,  True,  0, '-g3',                       Lang[ID_COPT_LINKERTAB],   [],       nil);
	AddOption(Lang[ID_COPT_NOLIBS],      False, True,  True,  True,  0, '-nostdlib',                 Lang[ID_COPT_LINKERTAB],   [],       nil);
	AddOption(Lang[ID_COPT_WIN32],       False, True,  True,  True,  0, '-mwindows',                 Lang[ID_COPT_LINKERTAB],   [dptGUI], nil);
	AddOption(Lang[ID_COPT_STRIP],       False, False, False, True,  0, '-s',                        Lang[ID_COPT_LINKERTAB],   [],       nil);

	// Architecture params
	sl := TStringList.Create;
	sl.Add(''); // /!\ Must contain a starting empty value in order to do not have always to pass the parameter
	sl.Add('This CPU=native');
	sl.Add('i386=i386');
	sl.Add('i486=i486');
	sl.Add('i586=i586');
	sl.Add('i686=i686');
	sl.Add('Pentium=pentium');
	sl.Add('Pentium MMX=pentium-mmx');
	sl.Add('Pentium Pro=pentiumpro');
	sl.Add('Pentium 2=pentium2');
	sl.Add('Pentium 3=pentium3');
	sl.Add('Pentium 4=pentium4');
	sl.Add('Conroe=core2');
	sl.Add('Nehalem=corei7');
	sl.Add('Sandy=corei7-avx');
	sl.Add('K6=k6');
	sl.Add('K6-2=k6-2');
	sl.Add('K6-3=k6-3');
	sl.Add('Athlon=athlon');
	sl.Add('Athlon Tbird=athlon-tbird');
	sl.Add('Athlon 4=athlon-4');
	sl.Add('Athlon XP=athlon-xp');
	sl.Add('Athlon MP=athlon-mp');
	sl.Add('K8=k8');
	sl.Add('K8 Rev.E=k8-sse3');
	sl.Add('K10=barcelona');
	sl.Add('Bulldozer=bdver1');
	AddOption(Lang[ID_COPT_ARCH], False, True, True, True, 0, '-march=', Lang[ID_COPT_GRP_CODEGEN], [], sl);

	// Built-in processor functions
	sl := TStringList.Create;
	sl.Add(''); // /!\ Must contain a starting empty value in order to do not have always to pass the parameter
	sl.Add('MMX=mmx');
	sl.Add('3D Now=3dnow');
	sl.Add('SSE=sse');
	sl.Add('SSE2=sse2');
	sl.Add('SSE3=sse3');
	sl.Add('SSSE3=ssse3');
	sl.Add('SSE4=sse4');
	sl.Add('SSE4A=sse4a');
	sl.Add('SSE4.1=sse4.1');
	sl.Add('SSE4.2=sse4.2');
	sl.Add('AVX=avx');
	sl.Add('FMA4=fma4');
	sl.Add('XOP=xop');
	sl.Add('AES=aes');
	AddOption(Lang[ID_COPT_BUILTINPROC], False, True, True, True, 0, '-m', Lang[ID_COPT_GRP_CODEGEN], [], sl);

	// Optimization
	sl := TStringList.Create;
	sl.Add('');
	sl.Add('Low=1');
	sl.Add('Med=2');
	sl.Add('High=3');
	sl.Add('Highest (fast)=fast');
	sl.Add('Size (s)=s');
	AddOption(Lang[ID_COPT_OPTIMIZE], False, True, True, True, 0, '-O', Lang[ID_COPT_GRP_CODEGEN], [], sl);

	// 32bit/64bit
	sl := TStringList.Create;
	sl.Add('');
	sl.Add('32bit=32');
	sl.Add('64bit=64');
	AddOption(Lang[ID_COPT_PTRWIDTH], False, True, True, True, 0, '-m', Lang[ID_COPT_GRP_CODEGEN], [], sl);

	// C++ Standards
	sl := TStringList.Create;
	sl.Add(''); // Passing nothing effectively lets the compiler decide
	sl.Add('ISO C90=c90');
	sl.Add('ISO C99=c99');
	sl.Add('ISO C++=c++98');
	sl.Add('ISO C++11=c++0x');
	sl.Add('GNU C90=gnu90');
	sl.Add('GNU C99=gnu99');
	sl.Add('GNU C++=gnu++98');
	sl.Add('GNU C++11=gnu++0x');
	AddOption(Lang[ID_COPT_STD], False, True, True, True, 0, '-std=', Lang[ID_COPT_GRP_CODEGEN], [], sl);
end;

procedure TdevCompiler.AddOption(_Name: string; _IsGroup, _IsC, _IsCpp, IsLinker: boolean; _Value: integer;_Setting, _Section: string; ExcludeFromTypes: TProjTypeSet; Choices: TStringList);
var
	option: PCompilerOption;
begin
	option := New(PCompilerOption);
	with option^ do begin
		optName := _Name;
		optIsGroup := _IsGroup;
		optIsC := _IsC;
		optIsCpp := _IsCpp;
		optIsLinker := IsLinker;
		optValue := _Value;
		optSetting := _Setting;
		optSection := _Section;
		optExcludeFromTypes := ExcludeFromTypes;
		optChoices := Choices;
	end;
	fOptions.Add(option);
end;

procedure TdevCompiler.ChangeOptionsLang;
begin
	ClearOptions;
	AddDefaultOptions;
	LoadSettings;
end;

procedure TdevCompiler.ClearOptions;
begin
	while fOptions.Count > 0 do begin
		if Assigned(PCompilerOption(fOptions[0]).optChoices) then
			PCompilerOption(fOptions[0]).optChoices.Free;
		if Assigned(fOptions[0]) then
			Dispose(fOptions[0]);
		fOptions.Delete(0);
	end;
end;

constructor TdevCompiler.Create;
begin
  inherited;
  fOptions := TList.Create;
  SettoDefaults;
  LoadSettings;
end;

procedure TdevCompiler.DeleteOption(Index: integer);
begin
  if Assigned(PCompilerOption(fOptions[Index]).optChoices) then
    PCompilerOption(fOptions[Index]).optChoices.Free;
  if Assigned(fOptions[Index]) then
    Dispose(fOptions[Index]);
  fOptions.Delete(Index);
end;

destructor TdevCompiler.Destroy;
begin
  ClearOptions;
  fOptions.Free;
  inherited;
end;

function TdevCompiler.FindOption(Setting: string; var opt: TCompilerOption; var Index: integer): boolean;
var
	I: integer;
begin
	Result:=False;
	for I:=0 to fOptions.Count-1 do
		if Options[I].optSetting = Setting then begin
			opt:=Options[I];
			Index:=I;
			Result:=True;
			Break;
		end;
end;

function TdevCompiler.GetOptions(Index: integer): TCompilerOption;
begin
  Result := TCompilerOption(fOptions[Index]^);
end;

function TdevCompiler.GetOptionStr: string;
var
	I: integer;
begin
	Result:='';
	for I := 0 to OptionsCount - 1 do
		Result:=Result+BoolVal10[Options[I].optValue];
end;

procedure TdevCompiler.LoadSettings;
var
	dummystring, key	: string;
	I,J					: integer;
	opt					: TCompilerOption;
begin
	with devData do begin
		// Figure out which set we're using
		CompilerSet := StrToIntDef(LoadSettingS('Compiler', 'CompilerSet'), 0);
		key := 'CompilerSets_' + IntToStr(CompilerSet);

		fUseParams:=      LoadSettingB(key, 'UseParams');
		fIntermediate:=   LoadSettingS(key, 'InterDir');
		fOutputDir:=      LoadSettingS(key, 'OutputDir');
		fRunParams:=      LoadSettingS(key, 'RunParams');
		fCompAdd:=        LoadSettingB(key, 'CompAdd');
		fLinkAdd:=        LoadSettingB(key, 'LinkAdd');
		fCompOpt:=        LoadSettingS(key, 'CompOpt');
		fLinkOpt:=        LoadSettingS(key, 'LinkOpt');

		fDelay:= strtointdef(LoadSettingS(key, 'Delay'),0);
		fFastDep:=        LoadSettingB(key, 'FastDep','1');

		dummystring :=    LoadSettingS(key, 'Options');
		for I := 0 to fOptions.Count - 1 do begin
			opt := Options[I];
			// Unknown options are set to false
			if (I >= Length(dummystring)) then
				opt.optValue := 0
			else
			// Else, scan boolval
				for J := 0 to 28 do begin
					if dummystring[I+1] = BoolVal10[J] then begin
						opt.optValue := J;
						Break;
					end;
				end;
			Options[I] := opt;
		end;
	end;
end;

function TdevCompiler.OptionsCount: integer;
begin
  Result := fOptions.Count;
end;

procedure TdevCompiler.SaveSettings;
begin
	with devData do
		SaveSettingS('Compiler', 'CompilerSet',  IntToStr(fCompilerSet));
end;

procedure TdevCompiler.SetCompilerSet(const Value: integer);
begin
	// If this one is already active
	if fCompilerSet=Value then Exit;

	// If we don't have this one yet (user created one)
	if not Assigned(devCompilerSet) then
		devCompilerSet:=TdevCompilerSet.Create;

	devCompilerSet.LoadSet(Value);

	// Programs
	fCompilerSet:=Value;
	if devDirs.OriginalPath = '' then // first time only
		devDirs.OriginalPath := GetEnvironmentVariable('PATH');

	SetPath(devDirs.Bins);
	fgccName := devCompilerSet.gccName;
	fgppName := devCompilerSet.gppName;
	fgdbName := devCompilerSet.gdbName;
	fmakeName := devCompilerSet.makeName;
	fwindresName := devCompilerSet.windresName;
	fdllwrapName := devCompilerSet.dllwrapName;
	fgprofName := devCompilerSet.gprofName;

	fCompOpt := devCompilerSet.CompOpts;
	fLinkOpt := devCompilerSet.LinkOpts;
	fCompAdd := devCompilerSet.AddToComp;
	fLinkAdd := devCompilerSet.AddToLink;

	fDelay := devCompilerSet.fDelay;
	fFastDep := devCompilerSet.fFastDep;
end;

procedure TdevCompiler.SetOptions(Index: integer;const Value: TCompilerOption);
begin
	with TCompilerOption(fOptions[Index]^) do begin
		optName := Value.optName;
		optIsGroup := Value.optIsGroup;
		optIsC := Value.optIsC;
		optIsCpp := Value.optIsCpp;
		optValue := Value.optValue;
		optSetting := Value.optSetting;
		optSection := Value.optSection;
	end;
end;

procedure TdevCompiler.SetOptionStr(const Value: string);
var
	I: integer;
begin
	for I := 0 to fOptions.Count - 1 do
		if (I < Length(Value)) then
			PCompilerOption(fOptions[I])^.optValue := ConvertCharToValue(Value[I + 1]);
end;

function TdevCompiler.ConvertCharToValue(c : char) : integer;
begin
  if c in ['a'..'z'] then
    result := integer(c) - integer('a') + 2
  else if (StrToIntDef(c, 0) = 1) then
    result := 1
  else
    result := 0;
end;

procedure TdevCompiler.SettoDefaults;
begin
	// Executable commands
	fRunParams:= '';
	fUseParams:= FALSE;
	fModified:= TRUE;

	// Everything else gets loaded from this set
	fCompilerSet:=0;

	// Fill option HWND's
	AddDefaultOptions;
end;

{ TDevDirs }

constructor TdevDirs.Create;
begin
	inherited Create;
	Name:= OPT_DIRS;
	SettoDefaults;
	LoadSettings;
end;

procedure TdevDirs.SettoDefaults;
begin
	fExec:= IncludeTrailingPathDelimiter(ExtractFilePath(Application.ExeName));

	if DirectoryExists(fExec + 'MinGW64') then begin
		fBinDir:= StringReplace(BIN_DIR64,        '%path%\',fExec,[rfReplaceAll]);
		fLibDir:= StringReplace(LIB_DIR64,        '%path%\',fExec,[rfReplaceAll]);
		fCDir  := StringReplace(C_INCLUDE_DIR64,  '%path%\',fExec,[rfReplaceAll]);
		fCppDir:= StringReplace(CPP_INCLUDE_DIR64,'%path%\',fExec,[rfReplaceAll]);
	end else if DirectoryExists(fExec + 'MinGW32') then begin
		fBinDir:= StringReplace(BIN_DIR32,        '%path%\',fExec,[rfReplaceAll]);
		fLibDir:= StringReplace(LIB_DIR32,        '%path%\',fExec,[rfReplaceAll]);
		fCDir  := StringReplace(C_INCLUDE_DIR32,  '%path%\',fExec,[rfReplaceAll]);
		fCppDir:= StringReplace(CPP_INCLUDE_DIR32,'%path%\',fExec,[rfReplaceAll]);
	end;

	fConfig := fExec;
	fHelp   := fExec + HELP_DIR;
	fIcons  := fExec + ICON_DIR;
	fLang   := fExec + LANGUAGE_DIR;
	fTemp   := fExec + TEMPLATE_DIR;
	fThemes := fExec + THEME_DIR;
end;

procedure TdevDirs.LoadSettings;
begin
  devData.LoadObject(Self);
  fExec:= IncludeTrailingPathDelimiter(ExtractFilePath(Application.ExeName));
  fHelp:=   StringReplace(fHelp,'  %path%\',fExec,[rfReplaceAll]);
  fIcons:=  StringReplace(fIcons, '%path%\',fExec,[rfReplaceAll]);
  fLang:=   StringReplace(fLang,  '%path%\',fExec,[rfReplaceAll]);
  fTemp:=   StringReplace(fTemp,  '%path%\',fExec,[rfReplaceAll]);
  fThemes:= StringReplace(fThemes,'%path%\',fExec,[rfReplaceAll]);
end;

procedure TdevDirs.SaveSettings;
begin
  fHelp :=  StringReplace(fHelp,fExec,  '%path%\',[rfReplaceAll]);
  fIcons:=  StringReplace(fIcons,fExec, '%path%\',[rfReplaceAll]);
  fLang:=   StringReplace(fLang,fExec,  '%path%\',[rfReplaceAll]);
  fTemp:=   StringReplace(fTemp,fExec,  '%path%\',[rfReplaceAll]);
  fThemes:= StringReplace(fThemes,fExec,'%path%\',[rfReplaceAll]);
  fLibDir:= StringReplace(fLibDir,fExec,'%path%\',[rfReplaceAll]);
  fBinDir:= StringReplace(fBinDir,fExec,'%path%\',[rfReplaceAll]);
  fCDir:=   StringReplace(fCDir,fExec,  '%path%\',[rfReplaceAll]);
  fCppDir:= StringReplace(fCppDir,fExec,'%path%\',[rfReplaceAll]);

  devData.SaveObject(Self);

  fHelp :=  StringReplace(fHelp,  '%path%\',fExec,[rfReplaceAll]);
  fIcons:=  StringReplace(fIcons, '%path%\',fExec,[rfReplaceAll]);
  fLang:=   StringReplace(fLang,  '%path%\',fExec,[rfReplaceAll]);
  fTemp:=   StringReplace(fTemp,  '%path%\',fExec,[rfReplaceAll]);
  fThemes:= StringReplace(fThemes,'%path%\',fExec,[rfReplaceAll]);
  fLibDir:= StringReplace(fLibDir,'%path%\',fExec,[rfReplaceAll]);
  fBinDir:= StringReplace(fBinDir,'%path%\',fExec,[rfReplaceAll]);
  fCDir:=   StringReplace(fCDir,  '%path%\',fExec,[rfReplaceAll]);
  fCppDir:= StringReplace(fCppDir,'%path%\',fExec,[rfReplaceAll]);
end;

constructor TdevEditor.Create;
begin
	inherited;
	Name:= OPT_EDITOR;

	fFont:= TFont.Create;
	fGutterfont:= TFont.Create;
	fSyntax:= TStringList.Create;
	TStringList(fSynTax).Duplicates:= dupIgnore;

	SettoDefaults;
	LoadSettings;
end;

destructor TdevEditor.Destroy;
begin
	fFont.Free;
	fGutterfont.Free;
	fSyntax.Free;
	inherited;
end;

procedure TdevEditor.LoadSettings;
begin
	devData.LoadObject(Self);
end;

procedure TdevEditor.SaveSettings;
begin
	devData.SaveObject(Self);
end;

procedure TdevEditor.SettoDefaults;
begin
	// General
	fAutoIndent:= TRUE;
	fInsertMode:= TRUE;
	fTabtoSpaces:= FALSE; // Use Tab Character (inverse)
	fSmartTabs:= FALSE;
	fGroupUndo:= TRUE;
	fInsDropFiles:= FALSE;
	fSpecialChar:= FALSE;

	// General #2
	fEHomeKey:= TRUE;
	fPastEOF:= FALSE;
	fPastEOL:= FALSE;
	fdblLine:= FALSE;
	fFindText:= TRUE;
	fShowScrollbars:= TRUE; // Show as needed
	fHalfPage:= FALSE;
	fShowScrollHint:= TRUE;
	fParserHints:= TRUE; // Editor hints
	fShowFunctionTip:= TRUE;

	// Caret
	fInsertCaret:= 0;
	fOverwriteCaret:= 3;
	fMatch := TRUE;

	// Margin
	fMarginVis:= TRUE;
	fMarginSize:= 80;
	fMarginColor:= cl3DLight;

	// Misc.
	fUseSyn:= TRUE;
	//last ; is for files with no extension
	//which should be treated as cpp header files
	fSynExt:= 'c;cpp;h;hpp;cc;cxx;cp;hp;rh;fx;inl;;';
	fHighCurrLine:= TRUE;
	fHighColor:= $FFFFCC; // Light Turquoise
	fTabSize:= 4;

	// Display
	fFont.name:= 'Courier New';
	fFont.Size:= 10;

	// Display #2
	fShowGutter:= TRUE;
	fGutterAuto:= TRUE;
	fCustomGutter:= FALSE;
	fLineNumbers:= TRUE;
	fFirstisZero:= FALSE;
	fLeadZero:= FALSE;
	fGutterFont.Name:= 'Courier New';
	fGutterFont.Size:= 10;
	fGutterSize:= 32;

	// Autosave
	fEnableAutoSave := FALSE;
	Interval := 10;
	fSaveType := 0;

	// Symbol completion
	fBraceComplete := TRUE;
	fParentheseComplete := TRUE;
	fIncludeComplete := TRUE;
	fCommentComplete := FALSE;
	fArrayComplete := TRUE;
	fCompleteSymbols := TRUE;
end;

procedure TdevEditor.AssignEditor(Editor: TSynEdit);
var
	pt,guttercolor: TPoint;
	x: integer;
begin
	if (not assigned(Editor)) or (not (Editor is TCustomSynEdit)) then exit;
	with Editor do begin
		BeginUpdate;
	try
		TabWidth:= fTabSize;
		Font.Assign(fFont);
		with Gutter do begin
			UseFontStyle:= fCustomGutter;
			Font.Assign(fGutterFont);
			Width:= fGutterSize;
			Visible:= fShowGutter;
			AutoSize:= fGutterAuto;
			ShowLineNumbers:= fLineNumbers;
			LeadingZeros:= fLeadZero;
			ZeroStart:= fFirstisZero;
			x:= fSyntax.IndexofName(cGut);
			if x <> -1 then begin
				// Hacky color fix
				guttercolor.x:= clBtnFace;
				guttercolor.y:= clBlack;
				fSyntax.Values[cGut]:= PointtoStr(guttercolor);
				StrtoPoint(pt, fSyntax.Values[cGut]);
				Color:= pt.x;
				Font.Color:= pt.y;
			end;
		end;

		if fMarginVis then
			RightEdge:= fMarginSize
		else
			RightEdge:= 0;

		RightEdgeColor:= fMarginColor;

		InsertCaret:= TSynEditCaretType(fInsertCaret);
		OverwriteCaret:= TSynEditCaretType(fOverwriteCaret);

		ScrollHintFormat:= shfTopToBottom;

		if HighCurrLine then
			ActiveLineColor := HighColor
		else
			ActiveLineColor := clNone;

		Options := [
			eoAltSetsColumnMode, eoDisableScrollArrows,
			eoDragDropEditing, eoDropFiles, eoKeepCaretX,
			eoRightMouseMovesCursor, eoScrollByOneLess, eoAutoSizeMaxScrollWidth
		];

		//Optional synedit options in devData
		if fAutoIndent then
			Options := Options + [eoAutoIndent];
		if fEHomeKey then
			Options := Options + [eoEnhanceHomeKey];
		if fGroupUndo then
			Options := Options + [eoGroupUndo];
		if fHalfPage then
			Options := Options + [eoHalfPageScroll];
		if fShowScrollbars then
			Options := Options + [eoHideShowScrollbars];
		if fPastEOF then
			Options := Options + [eoScrollPastEOF];
		if fPastEOL then
			Options := Options + [eoScrollPastEOL];
		if fShowScrollHint then
			Options := Options + [eoScrollHintFollows,eoShowScrollHint];
		if fSmartTabs then
			Options := Options + [eoSmartTabs];
		if fSmartTabs then
			Options := Options + [eoSmartTabDelete];
		if fTabtoSpaces then
			Options := Options + [eoTabsToSpaces];
		if fSpecialChar then
			Options := Options + [eoShowSpecialChars];

		finally
			EndUpdate;
		end;
	end;
end;

constructor TdevCodeCompletion.Create;
begin
 inherited Create;
 Name:= 'CodeCompletion';
 fCacheFiles:=TStringList.Create;
 SettoDefaults;
 LoadSettings;
end;

destructor TdevCodeCompletion.Destroy;
begin
  fCacheFiles.Free;
end;

procedure TdevCodeCompletion.LoadSettings;
begin
  devData.LoadObject(Self);
end;

procedure TdevCodeCompletion.SaveSettings;
begin
  devData.SaveObject(Self);
end;

procedure TdevCodeCompletion.SetDelay(Value: integer);
begin
	fDelay:=Value;
end;

procedure TdevCodeCompletion.SettoDefaults;
begin
	fWidth:=320;
	fHeight:=240;
	fDelay:=1000;
	fBackColor:=clWindow;
	fEnabled:=True;
	fUseCacheFiles:=False;
end;

{ TdevClassBrowsing }

constructor TdevClassBrowsing.Create;
begin
	inherited Create;
	Name:= 'ClassBrowsing';
	SettoDefaults;
	LoadSettings;
end;

procedure TdevClassBrowsing.LoadSettings;
begin
  devData.LoadObject(Self);
end;

procedure TdevClassBrowsing.SaveSettings;
begin
  devData.SaveObject(Self);
end;

procedure TdevClassBrowsing.SettoDefaults;
begin
	fEnabled:=True;
	fCBViewStyle:=0;

	fParseLocalHeaders:=False;
	fParseGlobalHeaders:=False;
	fShowFilter:=0;
	fUseColors:=True;
	fShowInheritedMembers:=False;
end;

{ TdevCVSHandler }

constructor TdevCVSHandler.Create;
begin
 inherited Create;
 Name:= 'CVSHandler';
 fRepositories:=TStringList.Create;
 SettoDefaults;
 LoadSettings;
end;

destructor TdevCVSHandler.Destroy;
begin
  fRepositories.Free;
end;

procedure TdevCVSHandler.LoadSettings;
begin
  devData.LoadObject(Self);
end;

procedure TdevCVSHandler.SaveSettings;
begin
  devData.SaveObject(Self);
end;

procedure TdevCVSHandler.SettoDefaults;
begin
   fExecutable:='cvs.exe';
   fCompression:=9;
   fUseSSH:=True;
end;

{ TdevCompilerSet }

procedure TdevCompilerSet.AssignToCompiler;
begin
	devCompiler.gccName:=devCompilerSet.gccName;
	devCompiler.gppName:=devCompilerSet.gppName;
	devCompiler.gdbName:=devCompilerSet.gdbName;
	devCompiler.makeName:=devCompilerSet.makeName;
	devCompiler.windresName:=devCompilerSet.windresName;
	devCompiler.dllwrapName:=devCompilerSet.dllwrapName;
	devCompiler.gprofName:=devCompilerSet.gprofName;

	// we have to set the devDirs too
	devDirs.Bins:=devCompilerSet.BinDir;
	devDirs.C:=devCompilerSet.CDir;
	devDirs.Cpp:=devCompilerSet.CppDir;
	devDirs.Lib:=devCompilerSet.LibDir;

	devCompiler.OptionStr:=fOptions;
end;

constructor TdevCompilerSet.Create;
begin
	inherited;
	fSets:=TStringList.Create;
	UpdateSets;
	SettoDefaults;
end;

destructor TdevCompilerSet.Destroy;
begin
  fSets.Free;
  inherited;
end;

procedure TdevCompilerSet.LoadSet(Index: integer);
var
	key, goodBinDir, goodCDir, goodCppDir, goodLibDir, msg, tempStr, gnumakereply, mingwmakereply: String;
begin
	if Index<0 then Exit;
	with devData do begin
		key:= OPT_COMPILERSETS+'_'+IntToStr(Index);

		// Programs
		fgccName :=     LoadSettingS(key, GCC_PROGRAM);
		fgppName :=     LoadSettingS(key, GPP_PROGRAM);
		fgdbName :=     LoadSettingS(key, GDB_PROGRAM);
		fmakeName :=    LoadSettingS(key, MAKE_PROGRAM);
		fwindresName := LoadSettingS(key, WINDRES_PROGRAM);
		fdllwrapName := LoadSettingS(key, DLLWRAP_PROGRAM);
		fgprofName :=   LoadSettingS(key, GPROF_PROGRAM);
		fOptions :=     LoadSettingS(key, 'Options');

		if fgccName=''     then fgccName:=     GCC_PROGRAM;
		if fgppName=''     then fgppName:=     GPP_PROGRAM;
		if fgdbName=''     then fgdbName:=     GDB_PROGRAM;
		if fmakeName=''    then fmakeName:=    MAKE_PROGRAM;
		if fwindresName='' then fwindresName:= WINDRES_PROGRAM;
		if fdllwrapName='' then fdllwrapName:= DLLWRAP_PROGRAM;
		if fgprofName=''   then fgprofName:=   GPROF_PROGRAM;

		fCompOpt:= LoadSettingS(key, 'CompOpt');
		fLinkOpt:= LoadSettingS(key, 'LinkOpt');
		fCompAdd:= LoadSettingB(key, 'CompAdd');
		fLinkAdd:= LoadSettingB(key, 'LinkAdd');

		fDelay:= strtointdef(LoadSettingS(key, 'Delay'),0);
		fFastDep:=        LoadSettingB(key, 'FastDep','1');

		// dirs
		devDirs.Exec   := IncludeTrailingPathDelimiter(ExtractFilePath(Application.ExeName));
		fBinDir := StringReplace(LoadSettingS(key, 'Bins'),'%path%\',devDirs.Exec,[rfReplaceAll]);
		fCDir   := StringReplace(LoadSettingS(key, 'C'),   '%path%\',devDirs.Exec,[rfReplaceAll]);
		fCppDir := StringReplace(LoadSettingS(key, 'Cpp'), '%path%\',devDirs.Exec,[rfReplaceAll]);
		fLibDir := StringReplace(LoadSettingS(key, 'Lib'), '%path%\',devDirs.Exec,[rfReplaceAll]);

		if fBinDir='' then fBinDir:=devDirs.Bins;
		if fCDir=''   then fCDir:=devDirs.C;
		if fCppDir='' then fCppDir:=devDirs.Cpp;
		if fLibDir='' then fLibDir:=devDirs.Lib;

		//check for valid paths
		msg := '';
		goodBinDir := ValidatePaths(fBinDir, tempStr);
		if tempStr <> '' then begin
			msg := msg + 'Following Bin directories don''t exist:' + #13#10;
			msg := msg + StringReplace(tempStr, ';', #13#10, [rfReplaceAll]);
			msg := msg + #13#10 + #13#10;
		end;
		goodCDir := ValidatePaths(fCDir, tempStr);
		if tempStr <> '' then  begin
			msg := msg + 'Following C Include directories don''t exist:' + #13#10;
			msg := msg + StringReplace(tempStr, ';', #13#10, [rfReplaceAll]);
			msg := msg + #13#10 + #13#10;
		end;
		goodCppDir := ValidatePaths(fCppDir, tempStr);
		if tempStr <> '' then begin
			msg := msg + 'Following C++ Include directories don''t exist:' + #13#10;
			msg := msg + StringReplace(tempStr, ';', #13#10, [rfReplaceAll]);
			msg := msg + #13#10 + #13#10;
		end;
		goodLibDir := ValidatePaths(fLibDir, tempStr);
		if tempStr <> '' then begin
			msg := msg + 'Following Libs directories don''t exist:' + #13#10;
			msg := msg + StringReplace(tempStr, ';', #13#10, [rfReplaceAll]);
			msg := msg + #13#10 + #13#10;
		end;
		if msg <> '' then begin
			msg := msg + 'Would you like Dev-C++ to remove them for you ';
			msg := msg + 'and add the default paths to the remaining existing paths?' + #13#10;
			msg := msg + 'Leaving those directories will lead to problems during compilation ';
			msg := msg + 'of any projects created with Dev-C++' + #13#10;
			msg := msg + #13#10;
			msg := msg + 'Unless you know exactly what you''re doing, it is recommended ';
			msg := msg + 'that you click Yes';

			// If confirmed, insert working dirs into default path list
			if MessageDlg(msg, mtConfirmation, [mbYes, mbNo], 0) = mrYes then begin
				fBinDir:= goodBinDir + ';' + StringReplace(BIN_DIR32,        '%path%\',devDirs.fExec,[rfReplaceAll]);
				fLibDir:= goodLibDir + ';' + StringReplace(LIB_DIR32,        '%path%\',devDirs.fExec,[rfReplaceAll]);
				fCDir  := goodCDir   + ';' + StringReplace(C_INCLUDE_DIR32,  '%path%\',devDirs.fExec,[rfReplaceAll]);
				fCppDir:= goodCppDir + ';' + StringReplace(CPP_INCLUDE_DIR32,'%path%\',devDirs.fExec,[rfReplaceAll]);
			end;
		end;
	end;

	// The code below checks for makefile processors...
	if devDirs.OriginalPath = '' then // first time only
		devDirs.OriginalPath := GetEnvironmentVariable('PATH');

	// First check if the current one exist
	SetPath(fBinDir);
	mingwmakereply := RunAndGetOutput(devCompilerSet.makeName + ' -v',fBinDir, nil, nil, nil);

	// If the currently selected Make does not reply
	if not AnsiStartsStr('GNU Make ', mingwmakereply) then begin

		// Try the old GNU one
		SetPath(fBinDir);
		gnumakereply := RunAndGetOutput('make.exe --v',fBinDir, nil, nil, nil);

		// Yay, there's an old make.exe in the bin directory!
		if AnsiStartsStr('GNU Make ', gnumakereply) then begin
			msg := 'Dev-C++ was unable to find the current make processor ('
			+ devCompilerSet.makeName  + ') in '
			+ fBinDir + ' with current settings, '
			+ 'however a probably older GNU make.exe has been found in that folder. '
			+ 'Would you like Dev-C++ to adjust the settings for you to '
			+ 'use GNU Make?'
			+ #13#10#13#10
			+ 'Unless you know exactly what you''re doing, it is recommended '
			+ 'that you click Yes.';

			if MessageDlg(msg, mtConfirmation, [mbYes, mbNo], 0) = mrYes then begin
				devCompilerSet.makeName := 'make.exe';
				devCompiler.makeName := 'make.exe';
			end;
		end else begin

			// Try MinGW
			SetPath(fBinDir);
			mingwmakereply := RunAndGetOutput('mingw32-make.exe -v',fBinDir, nil, nil, nil);

			if AnsiStartsStr('GNU Make ', mingwmakereply) then begin
				msg := 'Dev-C++ was unable to find the current make processor ('
				+ devCompilerSet.makeName  + ') in '
				+ fBinDir + ' with current settings, '
				+ 'however a MinGW mingw32-make.exe has been found in that folder. '
				+ 'Would you like Dev-C++ to adjust the settings for you to '
				+ 'use MinGW Make?'
				+ #13#10#13#10
				+ 'Unless you know exactly what you''re doing, it is recommended '
				+ 'that you click Yes.';
				if MessageDlg(msg, mtConfirmation, [mbYes, mbNo], 0) = mrYes then begin
					devCompilerSet.makeName := 'mingw32-make.exe';
					devCompiler.makeName := 'mingw32-make.exe';
				end;
			end else begin
				msg := 'There doesn''t seem to be any Make file in Dev-C++''s Bin path ('
				+ fBinDir + '). Please make sure that you have correctly set '
				+ 'GNU Make and adjust the Bin settings environment '
				+ 'variable and that the make setting in Compiler Option '
				+ 'contains a correct filename, otherwise you will not '
				+ 'be able to compile anything.';
				MessageDlg(msg, mtConfirmation, [mbOK], 0);
			end;
		end;
	end;
end;

procedure TdevCompilerSet.LoadSettings;
begin
	LoadSet(0);
end;

procedure TdevCompilerSet.SaveSet(Index: integer);
var
	key: string;
begin
	with devData do begin
		key:= OPT_COMPILERSETS+'_'+IntToStr(Index);

		// Programs
		SaveSettingS(key, GCC_PROGRAM,     fgccName);
		SaveSettingS(key, GPP_PROGRAM,     fgppName);
		SaveSettingS(key, GDB_PROGRAM,     fgdbName);
		SaveSettingS(key, MAKE_PROGRAM,    fmakeName);
		SaveSettingS(key, WINDRES_PROGRAM, fwindresName);
		SaveSettingS(key, DLLWRAP_PROGRAM, fdllwrapName);
		SaveSettingS(key, GPROF_PROGRAM,   fgprofName);
		SaveSettingS(key, 'Options',       fOptions);
		SaveSettingS(key, 'CompOpt',       fCompOpt);
		SaveSettingS(key, 'LinkOpt',       fLinkOpt);
		SaveSettingB(key, 'CompAdd',       fCompAdd);
		SaveSettingB(key, 'LinkAdd',       fLinkAdd);
		SaveSettingS(key, 'Delay',         inttostr(fDelay));
		SaveSettingB(key, 'FastDep',       fFastDep);

		// Paths
		SaveSettingS(key, 'Bins',  StringReplace(fBinDir,devDirs.fExec,'%path%\',[rfReplaceAll]));
		SaveSettingS(key, 'C',     StringReplace(fCDir,  devDirs.fExec,'%path%\',[rfReplaceAll]));
		SaveSettingS(key, 'Cpp',   StringReplace(fCppDir,devDirs.fExec,'%path%\',[rfReplaceAll]));
		SaveSettingS(key, 'Lib',   StringReplace(fLibDir,devDirs.fExec,'%path%\',[rfReplaceAll]));
	end;
end;

procedure TdevCompilerSet.SaveSettings;
begin
	WriteSets;
end;

function TdevCompilerSet.SetName(Index: integer): string;
begin
	if (Index>=0) and (Index<devCompilerSet.Sets.Count) then
		Result:=devCompilerSet.Sets[Index]
	else
		Result:=DEFCOMPILERSET32;
end;

procedure TdevCompilerSet.SettoDefaults;
begin
	// Programs
 	fgccName := GCC_PROGRAM;
	fgppName := GPP_PROGRAM;
	fgdbName := GDB_PROGRAM;
	fmakeName := MAKE_PROGRAM;
	fwindresName := WINDRES_PROGRAM;
	fdllwrapName := DLLWRAP_PROGRAM;
	fgprofName := GPROF_PROGRAM;

	// Command line text
	fCompAdd:= FALSE;
	fLinkAdd:= TRUE;
	fCompOpt:='';
	if DirectoryExists(devDirs.Exec + 'MinGW64') then
		fLinkOpt:='-static-libgcc'
	else
		fLinkOpt:='-static-libstdc++ -static-libgcc';

	// Makefile
	fDelay:=0;
	fFastDep:=TRUE;

	// dirs
	fBinDir := devDirs.Bins;
	fCDir   := devDirs.C;
	fCppDir := devDirs.Cpp;
	fLibDir := devDirs.Lib;

	fOptions:='';
end;

procedure TdevCompilerSet.UpdateSets;
var
  Ini: TIniFile;
  sl: TStringList;
  I: integer;
begin
  fSets.Clear;
  Ini:=TIniFile.Create(devData.INIFile);
  sl:=TStringList.Create;
  try
    Ini.ReadSectionValues(OPT_COMPILERSETS, sl);
    for I:=0 to sl.Count-1 do
      fSets.Add(sl.Values[sl.Names[I]]);
  finally
    sl.Free;
    Ini.Free;
  end;
end;

procedure TdevCompilerSet.WriteSets;
var
	Ini: TIniFile;
	I: integer;
begin
	Ini:=TIniFile.Create(devData.INIFile);
	try
		Ini.EraseSection(OPT_COMPILERSETS);
		for I:=0 to fSets.Count-1 do
			Ini.WriteString(OPT_COMPILERSETS, IntToStr(I), fSets[I]);
	finally
		Ini.Free;
	end;
end;

{ TdevExternalPrograms }

function TdevExternalPrograms.AddProgram(ext, prog: string): integer;
var
  idx: integer;
begin
  if ext='' then begin
    Result:=-1;
    Exit;
  end;

  idx:=AssignedProgram(ext);
  if idx=-1 then
    Result:=fPrograms.Add(ext+'='+prog)
  else begin
    fPrograms.Values[fPrograms.Names[idx]]:=prog;
    Result:=idx;
  end;
end;

function TdevExternalPrograms.AssignedProgram(ext: string): integer;
var
  I: integer;
begin
  Result:=-1;
  for I:=0 to fPrograms.Count-1 do
    if UpperCase(fPrograms.Names[I])=UpperCase(ext) then begin
      Result:=I;
      Break;
    end;
end;

constructor TdevExternalPrograms.Create;
begin
 inherited Create;
 Name:= 'ExternalPrograms';
 fPrograms:=TStringList.Create;
 SettoDefaults;
 LoadSettings;
end;

destructor TdevExternalPrograms.Destroy;
begin
  fPrograms.Free;
end;

function TdevExternalPrograms.GetProgramName(Index: integer): string;
begin
  Result:=fPrograms.Values[fPrograms.Names[Index]];
end;

procedure TdevExternalPrograms.LoadSettings;
begin
  devData.LoadObject(Self);
end;

procedure TdevExternalPrograms.SaveSettings;
begin
  devData.SaveObject(Self);
end;

procedure TdevExternalPrograms.SetToDefaults;
begin
  inherited;

end;

end.
