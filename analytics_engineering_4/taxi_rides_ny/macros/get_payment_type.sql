     {% macro get_payment_type(payment_type) -%}
        case
            when {{payment_type}} = 1 then 'Credit Card'
            when {{payment_type}} = 2 then 'Cash'
            when {{payment_type}} = 3 then 'No Charge'
        end as payment_type
    {% endmacro %}