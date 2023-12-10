module APB_sub
#(parameter start_value_ADDR = 4'h0,     // адрес регистра, в котором стартовое значение
  parameter subtract_value_ADDR = 4'h4,  // адрес регистра, в котором хранится вычитаемое значение
  parameter control_reg_ADDR = 4'h8,     // адрес контрольного регистра
  parameter current_result_ADDR = 4'hC)  // адрес  регистра текущего результата
(
    input wire PWRITE,            // сигнал, выбирающий режим записи или чтения (1 - запись, 0 - чтение)
    input wire PCLK,              // сигнал синхронизации
    input wire PSEL,              // сигнал выбора переферии 
    input wire [31:0] PADDR,      // Адрес регистра
    input wire [31:0] PWDATA,     // Данные для записи в регистр
    output reg [31:0] PRDATA = 0, // Данные, прочитанные из регистра
    input wire PENABLE,           // сигнал разрешения
    output reg PREADY = 0         // сигнал готовности (флаг того, что всё сделано успешно)
);


reg [31:0] start_value = 0;     // регистр стартового значения
reg [31:0] subtract_value = 0;  // вычитаемое значение
reg control_reg = 0;            // контрольный регистр, с помощью него производится операция вычитания (1 - проиводится вычитание, 0 - вычитания нет)
reg [31:0] current_result = 0;  // регистр текущего результат

reg flag = 0;   // индикатор того, изменялось ли стартовое значение или нет


always @(posedge PCLK) 
begin
    if (PSEL && !PWRITE && PENABLE) // Чтение из регистров 
     begin
        case(PADDR)
         start_value_ADDR:       PRDATA <= start_value;     // чтение по адресу регистра стартового значения
         subtract_value_ADDR:    PRDATA <= subtract_value;  // чтение по адресу регистра в котором хранится вычитаемое значение
         control_reg_ADDR:       PRDATA <= control_reg;     // чтение по адресу контрольного
         current_result_ADDR:    PRDATA <=current_result;   // чтение по адресу регистра текущего результата
        endcase
        PREADY <= 1'd1; // поднимаем флаг заверешения операции
     end

     else if(PSEL && PWRITE && PENABLE) // запись производится только регистр стартового значения, регистр с вычитаемым значением  и контрольный регистр
     begin
        case(PADDR)
         start_value_ADDR:      start_value    <= PWDATA ;     // запись по адресу регистра стартового значения
         subtract_value_ADDR:   subtract_value <= PWDATA;      // запись по адресу регистра в котором хранится вычитаемое значение
         control_reg_ADDR:      control_reg    <= PWDATA;
        endcase
        PREADY <= 1'd1; // поднимаем флаг заверешения операции
     end
   
   if (PREADY) // сбрасываем PREADY после выполнения записи или чтения
    begin
      PREADY <= !PREADY;
    end

    if(control_reg) // сбрасываем control_reg в 0 после выполнения операции вычитания
    begin
      control_reg <= !control_reg; 
    end

    if(flag) // сбрасываем флаг, после изменения текущего результата
    begin
       flag <= !flag; // опускаем флаг
    end
  end


always @(start_value) // если изменился регистр стартового значнения
begin
  flag <= 1; 
end

always @(posedge control_reg or posedge flag) // если значение контрольного регистра стало равным 1, то производится вычитание
begin
  if(flag) // если поднят флаг того, что изменилось стартовое значение
  begin
    current_result <= start_value; // текущ. значние = стартовое значение
  end

  else
  begin
    current_result <= current_result - subtract_value;  // вычитание
  end
end

//Коды запуска ракет
//iverilog -g2012 -o APB_sub.vvp APB_sub_tb.sv
//vvp APB_sub.vvp
endmodule