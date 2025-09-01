declare  @Language int =1 ;

select y.[إسم المندوب],y.[قطاع البيع],y.[كود العميل],y.[إسم العميل],y.[حد الإئتمان],y.[فترة الإئتمان],y.[رقم الفاتورة],y.[قيمة الفاتورة],y.[تاريخ الفاتورة],y.التحصيلات
,case when y.rank=1 then y.[الرصيد الحالى] else 0 end as 'الرصيد الحالى',y.[تاريخ السداد],y.[تاريخ سداد آخر دفعة],y.[تاريخ الإستحقاق],y.[عدد أيام تجاوز فترة الإئتمان],y.[إجمالى تجاوزات الشهر]
from(
SELECT EL.Description AS 'إسم المندوب', dbo.OrganizationLanguage.Description AS 'قطاع البيع', Customer.CustomerCode as 'كود العميل'
, dbo.CustomerLanguage.Description AS 'إسم العميل',Account.CreditLimit as 'حد الإئتمان',PT.SimplePeriodWidth as 'فترة الإئتمان'
		, [Transaction].TransactionID AS 'رقم الفاتورة'
, NetTotal as 'قيمة الفاتورة',TransactionDate as 'تاريخ الفاتورة', CP.AppliedAmount AS 'التحصيلات'
		,  case when TransactionTypeID=5 then ([transaction].RemainingAmount)*-1 else  ([transaction].RemainingAmount) end AS 'الرصيد الحالى',
		ROW_NUMBER() OVER(PARTITION BY [transaction].RemainingAmount ORDER BY [transaction].transactiondate )as 'rank'
		
		,CP.PaymentDate as 'تاريخ السداد',(select max (paymentdate) from CustomerPayment where CustomerPayment.TransactionID=CP.TransactionID) as 'تاريخ سداد آخر دفعة'
		,(DATEADD(day,pt.SimplePeriodWidth,[Transaction].TransactionDate ))as 'تاريخ الإستحقاق',
        case when  (datediff(DAY,DATEADD(day,pt.SimplePeriodWidth,[Transaction].TransactionDate ),CP.PaymentDate ))>0 
		then (datediff(DAY,DATEADD(day,pt.SimplePeriodWidth,[Transaction].TransactionDate ),CP.PaymentDate ))*1 else 0 end as 'عدد أيام تجاوز فترة الإئتمان',
		(select  sum(YY.[إجمالى تجاوزات الشهر]) from (select
case when (case when  (datediff(DAY,DATEADD(day,pt1.SimplePeriodWidth,TR.TransactionDate ),CP1.PaymentDate ))>0 
		then (datediff(DAY,DATEADD(day,PT1.SimplePeriodWidth,TR.TransactionDate ),CP1.PaymentDate ))*1 else 0 end )>0 
		  then count(TR.TransactionID)
end as 'إجمالى تجاوزات الشهر'
from [Transaction] TR 
 inner join CustomerPayment CP1 with(nolock) on tr.TransactionID=CP1.TransactionID
 inner join PaymentTerm PT1 on CP1.PaymentTypeID=PT1.PaymentTermID
 where TR.TransactionID=[Transaction].TransactionID and CP1.TransactionID=CP.TransactionID  and TR.CustomerID=[Transaction].CustomerID
 group by PT1.PaymentTermID,PT1.SimplePeriodWidth,tr.TransactionDate,CP1.PaymentDate
)YY)		 as 'إجمالى تجاوزات الشهر'
		
		
FROM customer


INNER JOIN dbo.CustomerLanguage ON CustomerLanguage.CustomerID = customer.CustomerID AND CustomerLanguage.LanguageID = @Language
INNER JOIN dbo.[Transaction] ON [Transaction].CustomerID = Customer.CustomerID
left JOIN dbo.OrganizationLanguage ON OrganizationLanguage.OrganizationID = [Transaction].OrganizationID AND OrganizationLanguage.LanguageID = @Language
INNER JOIN dbo.CustomerOutlet ON CustomerOutlet.CustomerID = Customer.CustomerID AND [Transaction].OutletID = CustomerOutlet.OutletID
left join EmployeeLanguage EL on [Transaction].EmployeeID=el.EmployeeID and el.LanguageID=@Language
inner join AccountCustOut with(nolock) on CustomerOutlet.CustomerID = AccountCustOut.CustomerID AND CustomerOutlet.OutletID = AccountCustOut.OutletID
inner join Account with(nolock) on AccountCustOut.AccountID = Account.AccountID
left join CustomerPayment CP with(nolock) on [Transaction].TransactionID=CP.TransactionID AND [Transaction].CustomerID = CP.CustomerID AND [Transaction].OutletID = CP.OutletID
left join PaymentTerm PT on CP.PaymentTypeID=PT.PaymentTermID
WHERE [Transaction].RemainingAmount > 0 
	AND Customer.Inactive != 1 AND CustomerOutlet.Inactive != 1 and voided != 1 and transactionTypeID in(1,6,5)
	group by [Transaction].TransactionID,OrganizationLanguage.Description,el.Description,Customer.CustomerCode,CustomerLanguage.Description,Account.CreditLimit
	,[Transaction].NetTotal,[Transaction].TransactionDate,[Transaction].RemainingAmount,[Transaction].CustomerID,CP.RemainingAmount,cp.PaymentDate,cp.TransactionID
	,PT.SimplePeriodWidth,PT.PaymentTermID,CP.AppliedAmount,[Transaction].TransactionTypeID
	)y

	order by 4 , 12 desc