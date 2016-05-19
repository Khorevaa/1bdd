//----------------------------------------------------------
//This Source Code Form is subject to the terms of the
//Mozilla Public License, v.2.0. If a copy of the MPL
//was not distributed with this file, You can obtain one
//at http://mozilla.org/MPL/2.0/.
//----------------------------------------------------------

/////////////////////////////////////////////////////////////////
//
// Объект-помощник для выполнения приемочного/BDD тестирования
//
//////////////////////////////////////////////////////////////////

// TODO в управляющем скрипте загружать текущий скрипт нужно через
// Контекст = Новый Структура("Контекст", Новый Структура("Журнал", Новый Структура));
// ИсполнительБДД = ЗагрузитьСценарий(ОбъединитьПути(ТекущийСценарий().Каталог, "../src/bdd-exec.os"), Контекст);
//
// Пример есть в коде теста
//

#Использовать logos
#Использовать asserts
#Использовать strings

Перем Лог;
Перем ЧитательГеркин;

Перем ПредставленияСтатусовВыполнения;
Перем ВозможныеСтатусыВыполнения;
Перем ВозможныеТипыШагов;
Перем ВозможныеКлючиПараметров;

Перем ТекущийУровень;

////////////////////////////////////////////////////////////////////
//{ Программный интерфейс

Функция ВыполнитьФичиИзКаталога(ФайлКаталога, ИскатьВПодкаталогах = Истина) Экспорт
	Лог.Отладка("Подготовка к выполнению сценариев в каталоге "+ФайлКаталога.ПолноеИмя);
	МассивФайлов = НайтиФайлы(ФайлКаталога.ПолноеИмя, "*.feature", ИскатьВПодкаталогах);

	НаборРезультатовВыполнения = Новый Массив;
	Для каждого ФайлФичи Из МассивФайлов Цикл
		Если ФайлФичи.ЭтоКаталог() Тогда
			ВызватьИсключение "Нашли каталог вместо файла-фичи "+ФайлФичи.ПолноеИмя;
		КонецЕсли;
		РезультатВыполнения = ВыполнитьФичу(ФайлФичи);
		НаборРезультатовВыполнения.Добавить(РезультатВыполнения);
	КонецЦикла;
	РезультатыВыполнения = СобратьЕдиноеДеревоИзНабораРезультатовВыполнения(НаборРезультатовВыполнения);
	Возврат РезультатыВыполнения;
КонецФункции // ВыполнитьФичиИзКаталога()

Функция ВыполнитьФичу(ФайлФичи) Экспорт
	Лог.Отладка("Подготовка к выполнению сценария "+ФайлФичи.ПолноеИмя);

	Лог.Отладка("Читаю фичу");

	РезультатыРазбора = ЧитательГеркин.ПрочитатьФайлСценария(ФайлФичи);

	РезультатыВыполнения = ВыполнитьДеревоФич(ФайлФичи, РезультатыРазбора);

	Возврат РезультатыВыполнения;
КонецФункции

Процедура ВывестиИтоговыеРезультатыВыполнения(РезультатыВыполнения) Экспорт
	МассивИтогов = Новый Массив;
	МассивИтогов.Добавить(ВозможныеТипыШагов.Функциональность);
	МассивИтогов.Добавить(ВозможныеТипыШагов.Сценарий);
	МассивИтогов.Добавить(ВозможныеТипыШагов.Шаг);

	СтруктураИтогов = Новый Структура;
	Для каждого Элем Из МассивИтогов Цикл
		СтруктураИтогов.Вставить(Элем, СтатусыВыполненияДляПодсчета());
	КонецЦикла;

	РекурсивноПосчитатьИтогиВыполнения(РезультатыВыполнения.Строки[0], СтруктураИтогов);

	ИмяПоляИтога = "Итог";
	Для каждого Итоги Из СтруктураИтогов Цикл
		ДобавитьОбщееКоличествоКИтогам(Итоги.Ключ, Итоги.Значение, ИмяПоляИтога);
	КонецЦикла;

	ТекущийУровень = 0;
	Лог.Информация("");

	Для каждого Элем Из МассивИтогов Цикл
		Итог = СтруктураИтогов[Элем];
		ВыводимИтог = Истина;
		Если Элем = ВозможныеТипыШагов.Функциональность И Итог[ИмяПоляИтога] = 1 Тогда
			ВыводимИтог = Ложь;
		КонецЕсли;
		Если ВыводимИтог Тогда
			ВывестиПредставлениеИтога(Итог, Элем, ИмяПоляИтога);
		КонецЕсли;
	КонецЦикла;

КонецПроцедуры

// Статусы выполнения тестов - ВАЖЕН порядок значение (0,1...), используется в ЗапомнитьСамоеХудшееСостояние
Функция ВозможныеСтатусыВыполнения() Экспорт
	Рез = Новый Структура;
	Рез.Вставить("НеВыполнялся", "0 Не выполнялся"); // использую подобное текстовое значение для удобных ассертов при проверке статусов выполнения
	Рез.Вставить("Пройден", "1 пройден");
	Рез.Вставить("НеРеализован", "2 не реализован");
	Рез.Вставить("Сломался", "3 Сломался");
	Возврат Новый ФиксированнаяСтруктура(Рез);
КонецФункции

Функция ВозможныеКодыВозвратовПроцесса() Экспорт
	Рез = Новый Соответствие;
	Рез.Вставить(ВозможныеСтатусыВыполнения.НеВыполнялся, 0);
	Рез.Вставить(ВозможныеСтатусыВыполнения.Пройден, 0);
	Рез.Вставить(ВозможныеСтатусыВыполнения.НеРеализован, 1);
	Рез.Вставить(ВозможныеСтатусыВыполнения.Сломался, 2);
	Возврат Рез;
КонецФункции // ВозможныеКодыВозвратовПроцесса()

Функция ИмяЛога() Экспорт
	Возврат "oscript.app.bdd";
КонецФункции

//}

////////////////////////////////////////////////////////////////////
//{ Реализация

Функция ВыполнитьДеревоФич(ФайлСценария, РезультатыРазбора)

	ДеревоФич = РезультатыРазбора.ДеревоФич;
	Ожидаем.Что(ДеревоФич, "Ожидали, что дерево фич будет передано как дерево значений, а это не так").ИмеетТип("ДеревоЗначений");

	РезультатыВыполнения = ДеревоФич.Скопировать();
	//РезультатыВыполнения.Колонки.Добавить("СтатусВыполнения");
	РекурсивноУстановитьСтатусДляВсехУзлов(РезультатыВыполнения.Строки[0], ВозможныеСтатусыВыполнения.НеВыполнялся);

	ИсполнительШагов = НайтиИсполнителяШагов(ФайлСценария);

	Рефлектор = Новый Рефлектор;
	МассивПараметров = Новый Массив;
	МассивПараметров.Добавить(ЭтотОбъект);
	МассивОписанийШагов = Рефлектор.ВызватьМетод(ИсполнительШагов, ЧитательГеркин.НаименованиеФункцииПолученияСпискаШагов(), МассивПараметров);

	РезультатыВыполнения.Строки[0].СтатусВыполнения = РекурсивноВыполнитьШаги(ИсполнительШагов, РезультатыВыполнения.Строки[0]);

	Возврат РезультатыВыполнения;
КонецФункции

Функция НайтиИсполнителяШагов(ФайлСценария)
	Лог.Отладка("Ищу исполнителя шагов в каталоге "+ФайлСценария.Путь);
	ПутьКИсполнителю = ОбъединитьПути(ФайлСценария.Путь, "step_definitions");
	ПутьКИсполнителю = ОбъединитьПути(ПутьКИсполнителю, ФайлСценария.ИмяБезРасширения+ ".os");

	ФайлИсполнителя = Новый Файл(ПутьКИсполнителю);
	Лог.Отладка("Ищу исполнителя шагов в файле "+ФайлИсполнителя.ПолноеИмя);

	Если Не ФайлИсполнителя.Существует() Тогда
		ВызватьИсключение "Файл исполнителя шагов не найден."+ФайлИсполнителя.ПолноеИмя;
	КонецЕсли;
	ИсполнительШагов = ЗагрузитьСценарий(ФайлИсполнителя.ПолноеИмя, Контекст);
	Возврат ИсполнительШагов;
КонецФункции

Функция РекурсивноВыполнитьШаги(ИсполнительШагов, Узел)
	ТекущийУровень = Узел.Уровень();
	ПредставлениеЛексемы = ?(Узел.ТипШага <> ВозможныеТипыШагов.Описание, Узел.Лексема +" ", "");
	Лог.Информация(ПредставлениеЛексемы + Узел.Тело);

	Лог.Отладка("Выполняю узел <"+Узел.ТипШага+">, тело <"+Узел.Тело+">");
	СтатусВыполнения = ВозможныеСтатусыВыполнения.НеВыполнялся;

	СтатусВыполнения = ВыполнитьШаг(ИсполнительШагов, Узел);

	Для Каждого СтрокаДерева Из Узел.Строки Цикл
		НовыйСтатус = РекурсивноВыполнитьШаги(ИсполнительШагов, СтрокаДерева);
		СтатусВыполнения = ЗапомнитьСамоеХудшееСостояние(СтатусВыполнения, НовыйСтатус);
		Если СтатусВыполнения <> ВозможныеСтатусыВыполнения.Пройден и СтрокаДерева.ТипШага = ВозможныеТипыШагов.Шаг Тогда
			Прервать;
		КонецЕсли;
	КонецЦикла;
	Узел.СтатусВыполнения = СтатусВыполнения;

	Если Узел.ТипШага <> ВозможныеТипыШагов.Шаг И Узел.ТипШага <> ВозможныеТипыШагов.Описание Тогда
		Лог.Информация("");
	КонецЕсли;

	Возврат СтатусВыполнения;
КонецФункции

Функция ВыполнитьШаг(ИсполнительШагов, Узел)

	СтатусВыполнения = ВозможныеСтатусыВыполнения.НеВыполнялся;
	Если Узел.ТипШага = ВозможныеТипыШагов.Шаг Тогда
		Рефлектор = Новый Рефлектор;

		СтрокаПараметров = "";
		МассивПараметров = Новый Массив;
		ПолучитьМассивПараметров(МассивПараметров, Узел.Параметры, СтрокаПараметров);
		ПолучитьМассивПараметров(МассивПараметров, Узел.ПараметрыДляТаблицы, СтрокаПараметров);

		СтрокаПараметров = Лев(СтрокаПараметров, СтрДлина(СтрокаПараметров)-1);
		Лог.Отладка(СтрШаблон("	Выполняю шаг <%1>, параметры <%2>", Узел.АдресШага, СтрокаПараметров));

		Попытка
			Рефлектор.ВызватьМетод(ИсполнительШагов, Узел.АдресШага, МассивПараметров);
			СтатусВыполнения = ВозможныеСтатусыВыполнения.Пройден;
		Исключение

			текстОшибки = ОписаниеОшибки();
			Если Найти(ИнформацияОбОшибке().Описание, ЧитательГеркин.ТекстИсключенияДляЕщеНеРеализованногоШага()) <> 0 Тогда
				СтатусВыполнения = ВозможныеСтатусыВыполнения.НеРеализован;
			ИначеЕсли Найти(ИнформацияОбОшибке().Описание, "Метод объекта не обнаружен") <> 0 Тогда
				СтатусВыполнения = ВозможныеСтатусыВыполнения.НеРеализован;
			Иначе
				СтатусВыполнения = ВозможныеСтатусыВыполнения.Сломался;
				Лог.Ошибка(текстОшибки);
			КонецЕсли;

		КонецПопытки;

		Если СтатусВыполнения <> ВозможныеСтатусыВыполнения.Пройден Тогда
			Отступ = ПолучитьОтступ(ТекущийУровень);
			Лог.Информация(Отступ + ПредставленияСтатусовВыполнения[СтатусВыполнения]);
		КонецЕсли;
	ИначеЕсли Узел.ТипШага = ВозможныеТипыШагов.Описание Тогда
		СтатусВыполнения = ВозможныеСтатусыВыполнения.Пройден;
	КонецЕсли;
	Узел.СтатусВыполнения = СтатусВыполнения;

	Возврат СтатусВыполнения;
КонецФункции

Процедура ПолучитьМассивПараметров(МассивПараметров, Знач Параметры, РезСтрокаПараметров)
	Если ЗначениеЗаполнено(Параметры) Тогда
		Для Каждого КлючЗначение Из Параметры Цикл
			МассивПараметров.Добавить(КлючЗначение.Значение);
			РезСтрокаПараметров = РезСтрокаПараметров + КлючЗначение.Значение + ",";
		КонецЦикла;
	КонецЕсли;

КонецПроцедуры

Функция СобратьЕдиноеДеревоИзНабораРезультатовВыполнения(НаборРезультатовВыполнения)
	РезультатВыполнения = ЧитательГеркин.СоздатьДеревоФич();
	СтатусВыполнения = ВозможныеСтатусыВыполнения.НеВыполнялся;

	Для каждого РезультатВыполненияФичи Из НаборРезультатовВыполнения Цикл
		Подстрока = РезультатВыполнения.Строки.Добавить();
		ЧитательГеркин.СкопироватьДерево(Подстрока, РезультатВыполненияФичи.Строки[0]);
		СтатусВыполнения = ЗапомнитьСамоеХудшееСостояние(СтатусВыполнения, Подстрока.СтатусВыполнения);
	КонецЦикла;
	Возврат РезультатВыполнения;
КонецФункции // СобратьЕдиноеДеревоИзНабораРезультатовВыполнения(НаборРезультатовВыполнения)

Процедура РекурсивноПосчитатьИтогиВыполнения(Узел, СтруктураИтогов)
	НужныйИтог = Неопределено;
	ЕстьИтог = СтруктураИтогов.Свойство(Узел.ТипШага, НужныйИтог);
	Если НЕ ЕстьИтог Тогда
		Возврат;
	КонецЕсли;

	НужныйИтог[Узел.СтатусВыполнения] = НужныйИтог[Узел.СтатусВыполнения] + 1;

	Для Каждого СтрокаДерева Из Узел.Строки Цикл
		РекурсивноПосчитатьИтогиВыполнения(СтрокаДерева, СтруктураИтогов);
	КонецЦикла;
КонецПроцедуры

Процедура ДобавитьОбщееКоличествоКИтогам(ИмяИтогов, Итоги, ИмяПоляИтога)
	Счетчик = 0;
	Для каждого Итог Из Итоги Цикл
		Счетчик = Счетчик + Итог.Значение;
	КонецЦикла;
	Итоги.Вставить(ИмяПоляИтога, Счетчик);
КонецПроцедуры

Процедура ВывестиПредставлениеИтога(Итог, ПредставлениеШага, ИмяПоляИтога)
	Представление = СтрШаблон("%9 %10 ( %1 %2, %3 %4, %5 %6, %7 %8 )",
		Итог[ВозможныеСтатусыВыполнения.Пройден], ПредставленияСтатусовВыполнения[ВозможныеСтатусыВыполнения.Пройден],
		Итог[ВозможныеСтатусыВыполнения.НеРеализован], ПредставленияСтатусовВыполнения[ВозможныеСтатусыВыполнения.НеРеализован],
		Итог[ВозможныеСтатусыВыполнения.Сломался], ПредставленияСтатусовВыполнения[ВозможныеСтатусыВыполнения.Сломался],
		Итог[ВозможныеСтатусыВыполнения.НеВыполнялся], ПредставленияСтатусовВыполнения[ВозможныеСтатусыВыполнения.НеВыполнялся],
		Итог[ИмяПоляИтога], ПредставлениеШага
		);
	Лог.Информация(Представление);
КонецПроцедуры

Процедура РекурсивноУстановитьСтатусДляВсехУзлов(Узел, НовыйСтатус)
	Узел.СтатусВыполнения = НовыйСтатус;

	Для Каждого СтрокаДерева Из Узел.Строки Цикл
		РекурсивноУстановитьСтатусДляВсехУзлов(СтрокаДерева, НовыйСтатус);
	КонецЦикла;
КонецПроцедуры

// Устанавливает новое текущее состояние выполнения тестов
// в соответствии с приоритетами состояний:
// 		Красное - заменяет все другие состояния
// 		Желтое - заменяет только зеленое состояние
// 		Зеленое - заменяет только серое состояние (тест не выполнялся ни разу).
Функция ЗапомнитьСамоеХудшееСостояние(ТекущееСостояние, НовоеСостояние)
	ТекущееСостояние = Макс(ТекущееСостояние, НовоеСостояние);
	Возврат ТекущееСостояние;

КонецФункции

// реализация интерфейс раскладки для логов
Функция Форматировать(Знач Уровень, Знач Сообщение) Экспорт
	Отступ = ПолучитьОтступ(ТекущийУровень);
	НаименованиеУровня = "";

	Если Уровень = УровниЛога.Информация Тогда
		НаименованиеУровня = ?(Лог.Уровень() <> Уровень, УровниЛога.НаименованиеУровня(Уровень) +Символы.Таб+ "- ", "");
		Возврат СтрШаблон("%3%1%2", Отступ, Сообщение, НаименованиеУровня);
	Иначе
		НаименованиеУровня = УровниЛога.НаименованиеУровня(Уровень);
		Отступ = СтрШаблон("- %1", Отступ);
		//Возврат СтрШаблон("%1 - %2 %3", НаименованиеУровня, Отступ, Сообщение);
	КонецЕсли;

	Возврат СтрШаблон("%1 %4 %2 %3", НаименованиеУровня, Отступ, Сообщение, Символы.Таб);

КонецФункции

Функция ПолучитьОтступ(Количество)
	Возврат СтроковыеФункции.СформироватьСтрокуСимволов(" ", Количество* 3);
КонецФункции

Функция ЗаполнитьПредставленияСтатусовВыполнения()
	Рез = Новый Соответствие;
	Рез.Вставить(ВозможныеСтатусыВыполнения.НеВыполнялся, "Не выполнялся");
	Рез.Вставить(ВозможныеСтатусыВыполнения.Пройден, "Пройден");
	Рез.Вставить(ВозможныеСтатусыВыполнения.НеРеализован, "Не реализован");
	Рез.Вставить(ВозможныеСтатусыВыполнения.Сломался, "Сломался");
	Возврат Рез;
КонецФункции

Функция СтатусыВыполненияДляПодсчета()
	Рез = Новый Соответствие;
	Рез.Вставить(ВозможныеСтатусыВыполнения.НеВыполнялся, 0);
	Рез.Вставить(ВозможныеСтатусыВыполнения.Пройден, 0);
	Рез.Вставить(ВозможныеСтатусыВыполнения.НеРеализован, 0);
	Рез.Вставить(ВозможныеСтатусыВыполнения.Сломался, 0);
	Возврат Рез;
КонецФункции // СтатусыВыполнения()

Функция Инициализация()
	Лог = Логирование.ПолучитьЛог(ИмяЛога());
	Лог.УстановитьРаскладку(ЭтотОбъект);

	ВозможныеСтатусыВыполнения = ВозможныеСтатусыВыполнения();
	ПредставленияСтатусовВыполнения = ЗаполнитьПредставленияСтатусовВыполнения();
	ТекущийУровень = 0;

	ЧитательГеркин = ЗагрузитьСценарий(ОбъединитьПути(ТекущийСценарий().Каталог, "gherkin-read.os"), Контекст);

	ВозможныеТипыШагов = ЧитательГеркин.ВозможныеТипыШагов();
	ВозможныеКлючиПараметров = ЧитательГеркин.ВозможныеКлючиПараметров();
КонецФункции

// }

///////////////////////////////////////////////////////////////////
// Точка входа

Инициализация();
