`timescale 1 ns / 1ns

module FPA_STUMPArchitecture ();

  // Parameter Definitions
  parameter PRPG_Size    = 64;
  parameter PRPG2_Size   = 12;
  parameter MISR_Size    = 32;
  parameter MISR2_Size    = 12;

  parameter Shift_Cnt    = 15;        // Scan_Size = 24
  parameter numOfTstCycl = 5;

  reg clk;
  wire [63:0] PRPG_Out1;
  wire [11:0] PRPG2_Out;
  integer sigFile,resultFile;
  integer cfgFile;
  reg i;
  integer status;
  integer faultFile;
  integer numOfFaults;
  integer numOfDetected;
  integer UNnumOfDetected;
  reg [31:0] Golden_MISR_Out;
  reg [11:0] Golden_MISR2_Out;
  wire [31:0] MISR_Out;
  wire [11:0] MISR2_Out;
  real coverage;
  reg [8*60:1] wireName;
  reg stuckAtVal;
  wire [31:0] PO;
  wire PRPG_En,PRPG2_En,MISR_En,MISR2_En;
      // Initial Seed Values
  reg [PRPG_Size - 1:0] PRPG_Seed ;
  reg [PRPG2_Size - 1:0] PRPG2_Seed ;
  reg [MISR_Size - 1:0] MISR_Seed ;
  reg [MISR2_Size - 1:0] MISR2_Seed ;
  reg [PRPG_Size - 1:0] PRPG_Poly ;
  reg [PRPG2_Size - 1:0] PRPG2_Poly ;
  reg [MISR2_Size - 1:0] MISR2_Poly ;
  reg [MISR_Size - 1:0] MISR_Poly ;
  reg masterRst;
  wire internalRst;
  wire done;
  wire ir_So, ac_So ,cntrl_So;
  wire ir_Si, ac_Si, pc_Si;
  wire NbarT;

  adder_net FUT (
    PRPG_Out1[31:0],
    PRPG_Out1[63:32],
    NbarT,
    clk,
    PO,
    ir_Si, ac_Si, pc_Si,
    ir_So, ac_So, cntrl_So
  );

  PRPG #(PRPG_Size) PRPG1 (
    clk,
    internalRst,
    PRPG_En,
    PRPG_Poly,
    PRPG_Seed,
    PRPG_Out1
  );

  PRPG #(PRPG2_Size) PRPG2 (
    clk,
    internalRst,
    PRPG2_En,
    PRPG2_Poly,
    PRPG2_Seed,
    PRPG2_Out
  );

  MISR #(MISR_Size) MISR_1 (
    clk,
    internalRst,
    MISR_En,
    MISR_Poly,
    MISR_Seed,
    PO,
    MISR_Out
  );

  MISR #(MISR2_Size) MISR_2 (
    clk,
    internalRst,
    MISR2_En,
    MISR2_Poly,
    MISR2_Seed,
    {3'b0, cntrl_So, 3'b0, ac_So, 3'b0, ir_So},
    MISR2_Out
  );

 assign {pc_Si,ac_Si,ir_Si} = {PRPG2_Out[8],PRPG2_Out[4],PRPG2_Out[0]};

  RTS_Controller #(Shift_Cnt, numOfTstCycl) RTS_Controller_1 (
    clk,
    masterRst,
    NbarT,
    internalRst,
    PRPG_En,
    PRPG2_En,
    MISR_En,
    MISR2_En,
    done
  );

  // Clock Inversion
  always #5 clk = !clk;

  // Initial Block
  always @(posedge clk) begin
    sigFile = $fopen("Signature.txt", "w");
    resultFile = $fopen("Reslt.txt", "w");
		
		clk = 0;
    cfgFile = $fopen("Configuration.txt", "r");
    i = 0;
    
    while (!$feof(cfgFile)) begin
      i = i + 1;
      status = $fscanf(cfgFile, "%h %h %h %h %h %h %h %h\n", PRPG_Poly, PRPG2_Poly, MISR_Poly, MISR2_Poly, PRPG_Seed, PRPG2_Seed, MISR_Seed, MISR2_Seed);
      masterRst = 1'b1; #1 masterRst = 1'b0;
      @(posedge done);
      $fwrite(sigFile, "%h %h\n", MISR_Out, MISR2_Out);
      // $fflush();
    end

    $fclose(sigFile);
    $fclose(cfgFile);
    #1;

    // End Dictionary of Good Signatures
    // $FaultCollapsing(adder_net, "AdderFaults.flt");
    i = 0;
    cfgFile = $fopen("Configuration.txt", "r");
    sigFile = $fopen("Signature.txt", "r");
    while (!$feof(cfgFile)) begin
      i = i + 1;
      status = $fscanf(sigFile, "%h %h\n", Golden_MISR_Out, Golden_MISR2_Out);
      status = $fscanf(cfgFile, "%h %h %h %h %h %h %h %h\n", PRPG_Poly, PRPG2_Poly, MISR_Poly, MISR2_Poly, PRPG_Seed, PRPG2_Seed, MISR_Seed, MISR2_Seed);
      #1;

      faultFile = $fopen("AdderFaults.flt", "r");
      numOfFaults = 0;
      numOfDetected = 0;
      UNnumOfDetected = 0;

      while (!$feof(faultFile)) begin
        status = $fscanf(faultFile, "%s s@%b\n", wireName, stuckAtVal);
        numOfFaults = numOfFaults + 1;
        $InjectFault(wireName, stuckAtVal);
        masterRst = 1'b1; #1 masterRst = 1'b0;

        @(posedge done);
        if ({MISR_Out, MISR2_Out} != {Golden_MISR_Out,Golden_MISR2_Out})
          numOfDetected = numOfDetected + 1;
        // else
        //   UNnumOfDetected = UNnumOfDetected + 1;
        //   $display("%h ,%h _%h ,%h", Golden_MISR_Out, MISR_Out, Golden_SISA_Out,SISA_Out);

        $RemoveFault(wireName);
      end 

      coverage = numOfDetected * 100.0 / numOfFaults;
      $display("F Coverage: %f/%f = %f", numOfDetected, numOfFaults, coverage);
      $fwrite(resultFile, "%h %h %h %h %h %h %h %h %d %d %f\n", PRPG_Poly, PRPG2_Poly, MISR_Poly, MISR2_Poly, PRPG_Seed, PRPG2_Seed, MISR_Seed, MISR2_Seed, numOfTstCycl, numOfTstCycl * Shift_Cnt, coverage);
    end 

    $stop;
  end
endmodule
