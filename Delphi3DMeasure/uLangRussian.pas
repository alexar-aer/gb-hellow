unit uLangRussian;

interface

// Russian String Constants
// Encoding: UTF-8 (with BOM recommended for Delphi 7 IDE editor visibility, but UTF-8 is key for runtime)

const
  // Menu Items
  SMenuFile = '&Файл';
  SMenuLoadModel = '&Загрузить модель (.obj)...';
  SMenuExit = 'В&ыход';
  
  SMenuView = '&Вид';
  SMenuWireframe = '&Каркас';
  SMenuSmooth = 'С&глаживание';
  SMenuResetView = 'С&брос вида';
  
  SMenuTools = '&Инструменты';
  SMenuAddPoint = '&Поставить точку на поверхности';
  SMenuClearPoints = '&Очистить все точки';
  SMenuSetScaleRef = 'Задать &масштаб (выбрать 2 точки)';
  
  SMenuLanguage = '&Язык';
  SMenuLangEn = '&English';
  SMenuLangRu = '&Русский';

  SMenuHelp = '&Справка';
  SMenuAbout = 'О &программе...';

  // UI Labels & Captions
  SCaptionMain = 'Инструмент измерения 3D моделей';
  SLabelDistance = 'Расстояние:';
  SLabelUnit = 'м';
  SLabelPoints = 'Точек:';
  SLabelScale = 'Масштаб:';
  
  SBtnExport = 'Экспорт в файл';
  SBtnClose = 'Закрыть';
  
  // Grid Columns
  SColIndex = '№';
  SColName = 'Название замера';
  SColValue = 'Значение (м)';
  SColStatus = 'Статус';

  // Messages
  SMsgLoading = 'Загрузка модели...';
  SMsgLoaded = 'Модель успешно загружена.';
  SMsgLoadError = 'Ошибка при загрузке файла модели.';
  SMsgSelectTwoPoints = 'Для установки масштаба выберите ровно две точки.';
  SMsgScaleSet = 'Масштаб установлен. 1 единица = 1 метр.';
  SMsgNoModel = 'Модель не загружена.';
  SMsgPointAdded = 'Точка добавлена на поверхность.';
  SMsgConfirmClear = 'Вы уверены, что хотите удалить все точки измерений?';
  
  // File Dialogs
  SFilterObj = 'Файлы OBJ (*.obj)|*.obj|Все файлы (*.*)|*.*';
  SFilterTxt = 'Текстовые файлы (*.txt)|*.txt|Все файлы (*.*)|*.*';
  STitleSave = 'Сохранить измерения';

implementation

end.
