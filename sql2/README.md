# Домашнее задание к занятию «SQL. Часть 2»

### Инструкция по выполнению домашнего задания

1. Сделайте fork [репозитория c шаблоном решения](https://github.com/netology-code/sys-pattern-homework) к себе в Github и переименуйте его по названию или номеру занятия, например, https://github.com/имя-вашего-репозитория/gitlab-hw или https://github.com/имя-вашего-репозитория/8-03-hw).
2. Выполните клонирование этого репозитория к себе на ПК с помощью команды `git clone`.
3. Выполните домашнее задание и заполните у себя локально этот файл README.md:
   - впишите вверху название занятия и ваши фамилию и имя;
   - в каждом задании добавьте решение в требуемом виде: текст/код/скриншоты/ссылка;
   - для корректного добавления скриншотов воспользуйтесь инструкцией [«Как вставить скриншот в шаблон с решением»](https://github.com/netology-code/sys-pattern-homework/blob/main/screen-instruction.md);
   - при оформлении используйте возможности языка разметки md. Коротко об этом можно посмотреть в [инструкции по MarkDown](https://github.com/netology-code/sys-pattern-homework/blob/main/md-instruction.md).
4. После завершения работы над домашним заданием сделайте коммит (`git commit -m "comment"`) и отправьте его на Github (`git push origin`).
5. Для проверки домашнего задания преподавателем в личном кабинете прикрепите и отправьте ссылку на решение в виде md-файла в вашем Github.
6. Любые вопросы задавайте в чате учебной группы и/или в разделе «Вопросы по заданию» в личном кабинете.

Желаем успехов в выполнении домашнего задания.

---

Задание можно выполнить как в любом IDE, так и в командной строке.

### Задание 1

Одним запросом получите информацию о магазине, в котором обслуживается более 300 покупателей, и выведите в результат следующую информацию: 
- фамилия и имя сотрудника из этого магазина;
- город нахождения магазина;
- количество пользователей, закреплённых в этом магазине.

```
SELECT s.store_id, s2.first_name, s2.last_name, c.city, COUNT(c2.customer_id) AS amaunt
FROM store s
JOIN staff s2 ON s2.store_id = s.store_id 
JOIN address a ON a.address_id = s2.address_id 
JOIN city c ON c.city_id = a.city_id 
JOIN customer c2 ON c2.store_id = s.store_id 
GROUP BY s.store_id, s2.first_name, s2.last_name, c.city
HAVING amaunt > 300;
```

![Task1](img/Screenshot_1.jpg)

### Задание 2

Получите количество фильмов, продолжительность которых больше средней продолжительности всех фильмов.

```
SELECT COUNT(*) FROM  film f
WHERE f.`length` > (SELECT  AVG(`length`) FROM film f2);
```

![Task1](img/Screenshot_2.jpg)

### Задание 3

Получите информацию, за какой месяц была получена наибольшая сумма платежей, и добавьте информацию по количеству аренд за этот месяц.

```
SELECT  DATE_FORMAT(p.payment_date, '%Y-%M') AS date, SUM(p.amount) AS 'amount of money', count(p.rental_id ) AS 'number of rents'
FROM payment p 
GROUP BY date
ORDER BY SUM(p.amount) DESC
limit 1;
```

![Task1](img/Screenshot_3.jpg)
