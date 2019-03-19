///////////////////////////////////////////////////////////////////////////////////////////////////
// Прикладной интерфейс

Процедура ОписаниеКоманды(Знач КомандаПриложения) Экспорт
	
	КомандаПриложения.Опция("a all", Ложь, "Установить все пакеты, зарегистрированные в хабе");
	КомандаПриложения.Опция("f file", "", "Указать файл из которого нужно установить пакет. Поддерживает указание маски файла для пакетной установки");
	КомандаПриложения.Опция("l local", Ложь, "Установить пакеты в локальный каталог oscript_modules");
	КомандаПриложения.Опция("N nid not-install-deps", Ложь, "признак отключения установки зависимых пакетов");
	КомандаПриложения.Опция("nca not-create-app", Ложь, "признак отключения создания файла запуска");
	КомандаПриложения.Опция("d dest", "", "Переопределить стандартный каталог в который устанавливаются пакеты (вместо oscript_modules)");

	КомандаПриложения.Аргумент("PACKAGE", "", "Имя пакета в хабе. Чтобы установить конкретную версию, используйте ИмяПакета@ВерсияПакета")
						.ТМассивСтрок()
						.Обязательный(Ложь);

	// КомандаПриложения.Спек = "(-a | --all | -l | --local | -d | --dest )";

КонецПроцедуры

Процедура ВыполнитьКоманду(Знач КомандаПриложения) Экспорт
	
	УстановкаВЛокальныйКаталог = КомандаПриложения.ЗначениеОпции("local");
	УстановкаВсехПакетов = КомандаПриложения.ЗначениеОпции("all");
	КаталогУстановки = КомандаПриложения.ЗначениеОпции("dest");
	ФайлПакетаУстановки = КомандаПриложения.ЗначениеОпции("file");
	МассивПакетовКУстановке = КомандаПриложения.ЗначениеАргумента("PACKAGE");

	НеобходимУстановитьЗависимости = Не КомандаПриложения.ЗначениеОпции("not-install-deps");
	СоздаватьФайлыЗапуска = НЕ КомандаПриложения.ЗначениеОпции("not-create-app");
	
	РежимУстановки = РежимУстановкиПакетов.Глобально;
	Если УстановкаВЛокальныйКаталог Тогда
		РежимУстановки = РежимУстановкиПакетов.Локально;
	КонецЕсли;
	
	ЦелевойКаталог = Неопределено;

	Если Не ПустаяСтрока(КаталогУстановки) Тогда
		ЦелевойКаталог = КаталогУстановки;
	КонецЕсли;
	Лог = Логирование.ПолучитьЛог(ПараметрыПриложенияOpm.ИмяЛогаСистемы());

	Если РежимУстановки = РежимУстановкиПакетов.Локально Тогда
		Лог.Предупреждение("При локальной установке параметр -dest игнорируется");
		ЦелевойКаталог = Неопределено;
	КонецЕсли;

    Лог.Отладка("УстановкаВЛокальныйКаталог: %1", УстановкаВЛокальныйКаталог);
    Лог.Отладка("УстановкаВсехПакетов: %1", УстановкаВсехПакетов);
    Лог.Отладка("КаталогУстановки: %1", КаталогУстановки);
    Лог.Отладка("ФайлПакетаУстановки: %1", ФайлПакетаУстановки);
    Лог.Отладка("МассивПакетовКУстановке: %1", МассивПакетовКУстановке.Количество());
	Лог.Отладка("НеобходимУстановитьЗависимости: %1", НеобходимУстановитьЗависимости);
    Лог.Отладка("СоздаватьФайлыЗапуска: %1", СоздаватьФайлыЗапуска);

	НастройкаУстановки = РаботаСПакетами.ПолучитьНастройкуУстановки();
	НастройкаУстановки.УстанавливатьЗависимости = НеобходимУстановитьЗависимости;
	НастройкаУстановки.СоздаватьФайлЗапуска = СоздаватьФайлыЗапуска;

	Если УстановкаВсехПакетов Тогда
		РаботаСПакетами.УстановитьВсеПакетыИзОблака(РежимУстановки, ЦелевойКаталог, НастройкаУстановки);
	ИначеЕсли ПустаяСтрока(ФайлПакетаУстановки) И МассивПакетовКУстановке.Количество() = 0 Тогда
		РаботаСПакетами.УстановитьПакетыПоОписаниюПакета(РежимУстановки, ЦелевойКаталог, НастройкаУстановки);
	ИначеЕсли НЕ ПустаяСтрока(ФайлПакетаУстановки) Тогда
		
		РазобранныйАдрес = СтрРазделить(ФайлПакетаУстановки, ПолучитьРазделительПути());
		Путь = ".";
		Маска = ФайлПакетаУстановки;
		Если РазобранныйАдрес.Количество() > 1 Тогда // отделим последнюю секцию как имя файла, а остальное опять соберем в строку пути
			
			Маска = РазобранныйАдрес[РазобранныйАдрес.Количество() - 1];
			РазобранныйАдрес.Удалить(РазобранныйАдрес.Количество() - 1);
			Путь = СтрСоединить(РазобранныйАдрес, ПолучитьРазделительПути());
			
		КонецЕсли;
		
		ФайлыПоМаске = НайтиФайлы(Путь, Маска);
		Для Каждого ФайлПакета Из ФайлыПоМаске Цикл
			
			РаботаСПакетами.УстановитьПакетИзФайла(ФайлПакета.ПолноеИмя, РежимУстановки, ЦелевойКаталог, НастройкаУстановки);
			
		КонецЦикла;
		
	Иначе

		Для каждого ИмяПакета Из МассивПакетовКУстановке Цикл
			РаботаСПакетами.УстановитьПакетИзОблака(ИмяПакета, РежимУстановки, ЦелевойКаталог);
		КонецЦикла;

	КонецЕсли;
	
КонецПроцедуры
