resident_load_msg: db 'Резидент загружен', 0dh, 0ah, '$'
resident_unload_success_msg: db 'Резидент выгружен', 0dh, 0ah, '$'
resident_unload_fail_msg: db 'Резидент не удалось выгрузить', 0dh, 0ah, '$'
ints_unload_msg: db 'Обработчики прерываний возвращены', 0dh, 0ah, '$'
env_unload_success_msg: db 'Переменные окружения выгружены', 0dh, 0ah, '$'
env_unload_fail_msg: db 'Переменные окружения не удалось выгрузить', 0dh, 0ah, '$'
clp_error_msg: db 'Ошибка параметров командной строки', 0dh, 0ah, '$'
help_msg: db 'F4 - Вывести сообщение ФИО, группа, вариант через 7 секунд', 0dh, 0ah
      db 'F5 - Перевести русскую букву М в italic режим', 0dh, 0ah
      db 'F6 - Русифицировать буквы ЪЫЬЮЭЯ', 0dh, 0ah
      db 'F7 - Запрет на ввод русских заглавных букв', 0dh, 0ah
      db 'F8 - Вывод нажатых символов в hex режиме', 0dh, 0ah, '$'
