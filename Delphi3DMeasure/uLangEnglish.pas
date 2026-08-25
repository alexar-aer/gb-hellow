unit uLangEnglish;

interface

// English String Constants
// Encoding: UTF-8

const
  // Menu Items
  SMenuFile = '&File';
  SMenuLoadModel = '&Load Model (.obj)...';
  SMenuExit = 'E&xit';
  
  SMenuView = '&View';
  SMenuWireframe = '&Wireframe';
  SMenuSmooth = '&Smooth Shading';
  SMenuResetView = '&Reset View';
  
  SMenuTools = '&Tools';
  SMenuAddPoint = '&Add Point on Surface';
  SMenuClearPoints = '&Clear All Points';
  SMenuSetScaleRef = 'Set &Scale Reference (Select 2 points)';
  
  SMenuLanguage = '&Language';
  SMenuLangEn = '&English';
  SMenuLangRu = '&Russian';

  SMenuHelp = '&Help';
  SMenuAbout = '&About...';

  // UI Labels & Captions
  SCaptionMain = '3D Body Measurement Tool';
  SLabelDistance = 'Distance:';
  SLabelUnit = 'm';
  SLabelPoints = 'Points:';
  SLabelScale = 'Scale Factor:';
  
  SBtnExport = 'Export to File';
  SBtnClose = 'Close';
  
  // Grid Columns
  SColIndex = '#';
  SColName = 'Measurement Name';
  SColValue = 'Value (m)';
  SColStatus = 'Status';

  // Messages
  SMsgLoading = 'Loading model...';
  SMsgLoaded = 'Model loaded successfully.';
  SMsgLoadError = 'Error loading model file.';
  SMsgSelectTwoPoints = 'Please select exactly two points to set the scale reference.';
  SMsgScaleSet = 'Scale reference set. 1 unit = 1 meter.';
  SMsgNoModel = 'No model loaded.';
  SMsgPointAdded = 'Point added on surface.';
  SMsgConfirmClear = 'Are you sure you want to clear all measurement points?';
  
  // File Dialogs
  SFilterObj = 'OBJ Files (*.obj)|*.obj|All Files (*.*)|*.*';
  SFilterTxt = 'Text Files (*.txt)|*.txt|All Files (*.*)|*.*';
  STitleSave = 'Save Measurements';

implementation

end.
