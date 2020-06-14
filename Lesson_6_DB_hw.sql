use vk;

/*������ 2
 * ��������� ������ �������� ������ ��� ��������� ��������� �� ������������ � user_id = 1.
 * ����� ���������� �������� ������, ����� �� ����������� ��������������� ����������. � ��� � �� ���������� ��� ��� ������ ���������.
 * 
 */

select to_user_id, count(to_user_id) as numbers
	from messages where from_user_id=1
	and (to_user_id in
	(
		(select target_user_id from friend_requests where (initiator_user_id = 1) and (status = 'approved'))
		union 
		(select initiator_user_id from friend_requests where (target_user_id = 1) and (status = 'approved'))
	)
	)
group by to_user_id order by numbers desc limit 1;

/* ����� ������� � ������������ � �������� ��������� � �������� ������������ ������� UNION 
 * 
 * 
 * ����� �������� � �������� ������� �� �������� � ��������� ��� ������������ c user_id = 1 (������������� ������), 
 * �� ��� �������� � ���� �������� �� �������. 
 * select to_user_id as user_id, count(to_user_id) as numbers from messages where from_user_id=1 group by to_user_id
union all
select from_user_id, count(from_user_id) from messages where to_user_id=1 group by from_user_id; 

 ���� ����� ������ 
 
  select * from 
(select to_user_id as user_id, count(to_user_id) as numbers from messages where from_user_id=1 group by to_user_id
union all
select from_user_id, count(from_user_id) from messages where to_user_id=1 group by from_user_id);
�������� � ������ 

 QL Error [1248] [42000]: Every derived table must have its own alias 
 * */



/*������ 3. 
 * ������������� � ������ ����� ������
 * 
 * select * from likes where userid in (select userid from profiles order by birthday desc limit 10);
 * ������� ����� ������ SQL Error [1235] [42000]: This version of MySQL doesn't yet support 'LIMIT & IN/ALL/ANY/SOME subquery'
 * 
 * ��������� ����������� �������� ������ �� 
 * COUNT(*)
FROM likes
WHERE userid IN ( SELECT userid FROM profiles WHERE TIMESTAMPDIFF (YEAR, NOW(), birthday) < 10
);
 * ���� ������ �� ����������� �������� ������. �� � ������� ����� ���� �������������. � �������� ������� ���� ������,
 * ������� ������� NOW() � birthday. 
 * �� ������� ����� ���� ������������� ������ 10 ���. 
 */
select count(*) from likes where user_id in (select user_id from profiles where TIMESTAMPDIFF (YEAR, birthday, NOW()) < 10);

/*������ 4. ����� ����� ��� ����������.*/

select  
case (select gender from profiles where user_id = id)
	when 'f' then '�������'
	when 'm' then '�������'
end as gender_l,
count(*) as Number_of_likes from likes group by gender_l order by Number_of_likes desc limit 1;

/*������ 5. � ������� union �� ���������� ��������� ������. �������� ������� �������������� ������� � � ��� ��������*/


drop table if exists table_of_activite;
create table table_of_activite (
	id SERIAL primary key,
	user_id BIGINT unsigned not null,
	numbers_of_activity BIGINT unsigned not null,
	foreign key (user_id) references users(id)
);

insert into `table_of_activite` (`user_id`,`numbers_of_activity`)  select user_id, count(user_id) from media group by user_id;
insert into `table_of_activite` (`user_id`,`numbers_of_activity`)  select user_id, count(user_id) from likes group by user_id;
insert into `table_of_activite` (`user_id`,`numbers_of_activity`)  select initiator_user_id, count(initiator_user_id) from friend_requests group by initiator_user_id;
/*����� ���������� �������� ����� �� ��������� �����������, ��������, �� ������� messages, � ����������*/
select user_id, sum(numbers_of_activity) as total_number from table_of_activite group by user_id order by total_number limit 10;

/*������ ����� UNION ������� ������*/
select user_id, sum(numbers_of_act) as tot_number from 
(select user_id, count(user_id) as numbers_of_act from media group by user_id
union all
select user_id, count(user_id) from likes group by user_id) 

group by user_id order by tot_number limit 10;
