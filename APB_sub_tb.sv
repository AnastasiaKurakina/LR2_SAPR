`include "APB_master.sv"
`include "APB_sub.sv"
module APB_sub_tb;



reg PCLK = 0;                   // сигнал синхронизации
reg PWRITE_MASTER = 0;          // сигнал, выбирающий режим записи или чтения (1 - запись, 0 - чтение)
wire PSEL;                      // сигнал выбора переферии
//reg PSEL = 0; 
reg [31:0] PADDR_MASTER = 0;    // Адрес регистра
reg [31:0] PWDATA_MASTER = 0;   // Данные для записи в регистр
wire [31:0] PRDATA_MASTER;       // Данные, прочитанные из слейва
wire PENABLE;                    // сигнал разрешения, формирующийся в мастер APB
reg PRESET = 0;                   // сигнал сброса
wire PREADY;                      // сигнал готовности (флаг того, что всё сделано успешно)
wire [31:0] PADDR;                // адрес, который мы будем передавать в слейв
wire [31:0] PWDATA;               // данные, которые будут передаваться в слейв,
wire [31:0] PRDATA ;              // данные, прочтённые с слейва
wire PWRITE;                      // сигнал записи или чтения на вход слейва

APB_master APB_master_1 (
    .PCLK(PCLK),
    .PWRITE_MASTER(PWRITE_MASTER),
    .PSEL(PSEL),
    .PADDR_MASTER(PADDR_MASTER),
    .PWDATA_MASTER(PWDATA_MASTER),
    .PRDATA_MASTER(PRDATA_MASTER),
    .PENABLE(PENABLE),
    .PRESET(PRESET),
    .PREADY(PREADY),
    .PADDR(PADDR),
    .PWDATA(PWDATA),
    .PRDATA(PRDATA),
    .PWRITE(PWRITE)
);

APB_sub APB_sub_1 (
    .PWRITE(PWRITE),
    .PSEL(PSEL),
    .PADDR(PADDR),
    .PWDATA(PWDATA),
    .PRDATA(PRDATA),
    .PENABLE(PENABLE),
    .PREADY(PREADY),
    .PCLK(PCLK)
);



always #200 PCLK = ~PCLK; // генерация входного сигнала Pclk

initial begin
    
PCLK = 0;
@(posedge PCLK);

// Запись в регистр start_value
PWRITE_MASTER = 1;           // выбираем запись
PWDATA_MASTER = 32'd15;    // записываем 32-х разрядное десятичное число 15
PADDR_MASTER = 4'h0;       // выбираем адрес регистра start_value_ADDR
@(posedge PCLK);
@(posedge PCLK);


// Запись в регистр subtract_value_ADDR
PWRITE_MASTER = 1;           // выбираем запись
PWDATA_MASTER = 32'd3;    // записываем 32-х разрядное десятичное число 3
PADDR_MASTER = 4'h4;       // выбираем адрес регистра subtract_value_ADDR
@(posedge PCLK);
@(posedge PCLK);


//Производим вычитание
PWRITE_MASTER = 1;           // выбираем запись
PWDATA_MASTER = 1;         // записываем 1
PADDR_MASTER = 4'h8;       // выбираем адрес регистра control reg
@(posedge PCLK);
@(posedge PCLK);


//Производим вычитание
PWRITE_MASTER = 1;           // выбираем запись
PWDATA_MASTER = 1;         // записываем 1
PADDR_MASTER = 4'h8;       // выбираем адрес регистра control reg
@(posedge PCLK);
@(posedge PCLK);

// Запись в регистр subtract_value_ADDR
PWRITE_MASTER = 1;       // выбираем запись
PWDATA_MASTER = 32'd19;   // записываем 32-х разрядное десятичное число 19
PADDR_MASTER = 4'h4;     // выбираем адрес регистра subtract_value_ADDR
@(posedge PCLK);
@(posedge PCLK);


//Производим вычитание (9 - 19 = -10) в результате получим число FFFFFFF6, которое является доп кодом числа -10
PWRITE_MASTER = 1;           // выбираем запись
PWDATA_MASTER = 1;         // записываем 1
PADDR_MASTER = 4'h8;       // выбираем адрес регистра control reg
@(posedge PCLK);
@(posedge PCLK);

// Запись в регистр start_value
PWRITE_MASTER = 1;           // выбираем запись
PWDATA_MASTER = 32'd5;    // записываем 32-х разрядное десятичное число 15
PADDR_MASTER = 4'h0;       // выбираем адрес регистра start_value_ADDR
@(posedge PCLK);
@(posedge PCLK);

// Чтение из регистра start_value
PWRITE_MASTER = 0;           // выбираем чтение
PADDR_MASTER = 4'h0;       // выбираем адрес регистра start_value_ADDR
@(posedge PCLK);
@(posedge PCLK);

// Чтение из регистра subtract_value_ADDR
PWRITE_MASTER = 0;           // выбираем чтение
PADDR_MASTER = 4'h4;       // выбираем адрес регистра subtract_value
@(posedge PCLK);
@(posedge PCLK);

// Чтение из регистра current_result
PWRITE_MASTER = 0;           // выбираем чтение
PADDR_MASTER = 4'hC;       // выбираем адрес регистра current_result
@(posedge PCLK);
@(posedge PCLK);

 #500 $finish; // Заканчиваем симуляцию
end







initial begin
$dumpfile("APB_sub.vcd"); // создание файла для сохранения результатов симуляции
$dumpvars(0, APB_sub_tb); // установка переменных для сохранения в файле
$dumpvars;
end


endmodule