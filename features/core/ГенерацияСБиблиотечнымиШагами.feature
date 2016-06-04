# language: ru

Функционал: Проверка генерации шагов
	Как Разработчик
	Я Хочу генерировать шаги в os-файлах шагов фич с учетом библиотечных шагов

Контекст:

  Допустим я подготовил тестовый каталог для фич
  И установил тестовый каталог как текущий
  И я подготовил специальную тестовую фичу "ПередачаПараметров"
  И я подставил файл шагов с уже реализованными шагами для фичи "ПередачаПараметров"
  И я создал файл фичи "ФичаБезШагов" с текстом
  """
    # language: ru
    Функционал: Библиотечные шаги
    Сценарий: Использование шагов из другой фичи
      Когда я передаю параметр "Минимальный"
      Тогда я получаю параметр "Минимальный"
  """

Структура сценария: Первичная генерация - <Сценарий>

  Когда я запустил генерацию шагов фичи "ФичаБезШагов" с передачей параметра <ПараметрКоманднойСтроки>
  Тогда я не получил сгенерированный os-файл "ФичаБезШагов" в ожидаемом каталоге
  И проверка поведения фичи "ФичаБезШагов" закончилась с кодом возврата 0

Примеры:
	| Сценарий | ПараметрКоманднойСтроки |
	| Библиотечные шаги находятся в одном файле | -require ПередачаПараметров.feature |
	| Автоматическая загрузка всех шагов как библиотечных из каталога фичи |  |

 Структура сценария: Перегенерация шагов в случае существования файла шагов - <Сценарий>
 
 	# Когда я подготовил тестовый каталог для фич
   # И установил тестовый каталог как текущий
   # Когда я подготовил специальную тестовую фичу "ПередачаПараметров"
   # И я подставил файл шагов с уже реализованными шагами для фичи "ПередачаПараметров"
   И я запустил генерацию шагов фичи "ПередачаПараметров" с передачей параметра <ПараметрКоманднойСтроки>
   Тогда я получил сгенерированный os-файл "ПередачаПараметров" в ожидаемом каталоге
 	И проверка поведения фичи "ПередачаПараметров" закончилась с кодом возврата 0
 
 Примеры:
 	| Сценарий | ПараметрКоманднойСтроки |
 	| Библиотечные шаги находятся в одном файле | -require ПередачаПараметров.feature |
 	| Автоматическая загрузка всех шагов как библиотечных из каталога фичи |  |
 
Контекст:

	Когда я подготовил тестовый каталог для фич
	И установил тестовый каталог как текущий
	И я создал еще один каталог "lib"
	И установил каталог "lib" как текущий
	И я подготовил специальную тестовую фичу "ПередачаПараметров"
	И я подставил файл шагов с уже реализованными шагами для фичи "ПередачаПараметров"
	И установил тестовый каталог как текущий
	И я создал файл фичи "ФичаБезШагов" с текстом
	"""
		# language: ru
		Функционал: Библиотечные шаги
		Сценарий: Использование шагов из другой фичи
			Когда я передаю параметр "Минимальный"
			Тогда я получаю параметр "Минимальный"
	"""

Структура сценария: Первичная генерация - <Сценарий>

	Когда я запустил генерацию шагов фичи "ФичаБезШагов" с передачей параметра <ПараметрКоманднойСтроки>
	Тогда я не получил сгенерированный os-файл "ФичаБезШагов" в ожидаемом каталоге
	И проверка поведения фичи "ФичаБезШагов" закончилась с кодом возврата 0

Примеры:
	| Сценарий | ПараметрКоманднойСтроки |
	| Библиотечные шаги находятся в каталоге | -require lib |
	| Автоматическая загрузка всех шагов как библиотечных из подкаталогов каталога фичи |  |

# # Сценарий: Перегенерация шагов в случае существования файла шагов
# # 
# # 	Когда я подготовил тестовый каталог для фич
# #   И установил тестовый каталог как текущий
# #   Когда я подготовил специальную тестовую фичу "ПередачаПараметров"
# #   И я подставил файл шагов с уже реализованными шагами для фичи "ПередачаПараметров"
# #   И я запустил генерацию шагов фичи "ПередачаПараметров"
# #   Тогда я получил сгенерированный os-файл "ПередачаПараметров" в ожидаемом каталоге
# # 	И проверка поведения фичи "ПередачаПараметров" закончилась с кодом возврата 0
