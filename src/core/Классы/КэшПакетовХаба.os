﻿
#Использовать logos

Перем Лог;

Перем ПакетыХаба;

Процедура ПриСозданииОбъекта()
	
	Обновить();

КонецПроцедуры

Процедура Обновить() Экспорт

	ПакетыХаба = Новый Соответствие;
	
	Репо = Новый Репо();

	СоответствиеПакетов = Репо.ПолучитьПакеты();
	Для каждого КлючЗначение из СоответствиеПакетов Цикл
		ПакетыХаба.Вставить(КлючЗначение.Ключ, Истина);
	КонецЦикла;
	
КонецПроцедуры

Функция ЭтоПакетХаба(Знач ИмяПакета) Экспорт

	Возврат ПакетыХаба[ИмяПакета] = Истина;

КонецФункции

Функция ПолучитьПакетыХаба() Экспорт

	Возврат ПакетыХаба;

КонецФункции	

Процедура Инициализация()

	Лог = Логирование.ПолучитьЛог("oscript.app.opm");
	
КонецПроцедуры

Инициализация();
