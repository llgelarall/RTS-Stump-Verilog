`timescale 1 ns / 1ns

module FPA_RTSArchitecture ();

  // Parameter Definitions
  parameter PRPG_Size    = 64;
  parameter SRSG_Size    = 64;
  parameter MISR_Size    = 32;
  parameter SISA_Size    = 45;
  parameter Shift_Cnt    = 45;        // Scan_Size = 24
  parameter numOfTstCycl = 5;

  reg clk;
  wire [63:0] PRPG_Out1,PRPG_Out2;
  integer sigFile,resultFile;
  integer cfgFile;
  reg i;
  integer status;
  integer faultFile;
  integer numOfFaults;
  integer numOfDetected;
  integer UNnumOfDetected;
  reg [31:0] Golden_MISR_Out;
  reg [44:0] Golden_SISA_Out;
  wire [44:0] SISA_Out;
  wire [31:0] MISR_Out;
  real coverage;
  reg [8*60:1] wireName;
  reg stuckAtVal;
  wire [31:0] PO;
  wire PRPG_En,MISR_En,SISA_En,SRSG_En;
      // Initial Seed Values
  reg [PRPG_Size - 1:0] PRPG_Seed ;
  reg [SRSG_Size - 1:0] SRSG_Seed ;
  reg [MISR_Size - 1:0] MISR_Seed ;
  reg [SISA_Size - 1:0] SISA_Seed ;
  reg [PRPG_Size - 1:0] PRPG_Poly ;
  reg [SRSG_Size - 1:0] SRSG_Poly ;
  reg [MISR_Size - 1:0] MISR_Poly ;
  reg [SISA_Size - 1:0] SISA_Poly ;
  reg masterRst;
  wire internalRst;
  wire done;
  wire So;
  wire Si;
  wire NbarT;
  // Module Instantiations
  adder_net FUT (
    PRPG_Out1[31:0],
    PRPG_Out1[63:32],
    NbarT, Si,
    clk,
    PO,
    So
  );

  PRPG #(PRPG_Size) PRPG1 (
    clk,
    internalRst,
    PRPG_En,
    PRPG_Poly,
    PRPG_Seed,
    PRPG_Out1
  );
  //   PRPG #(PRPG_Size) PRPG2 (
  //   clk,
  //   internalRst,
  //   PRPG_En,
  //   PRPG_Poly2,
  //   PRPG_Seed,
  //   PRPG_Out2
  // );

  MISR #(MISR_Size) MISR_1 (
    clk,
    internalRst,
    MISR_En,
    MISR_Poly,
    MISR_Seed,
    PO,
    MISR_Out
  );

  SRSG #(SRSG_Size) SRSG_1 (
    clk,
    internalRst,
    SRSG_En,
    SRSG_Poly,
    SRSG_Seed,
    Si
  );

  SISA #(SISA_Size) SISA_1 (
    clk,
    internalRst,
    SISA_En,
    SISA_Poly,
    SISA_Seed,
    So,
    SISA_Out
  );

  RTS_Controller #(Shift_Cnt, numOfTstCycl) RTS_Controller_1 (
    clk,
    masterRst,
    NbarT,
    internalRst,
    PRPG_En,
    SRSG_En,
    SISA_En,
    MISR_En,
    done
  );

  // Clock Inversion
  always #5 clk = !clk;

  // Initial Block
  always @(posedge clk) begin
    sigFile = $fopen("Signature.txt", "w");
    resultFile = $fopen("Reslt.txt", "w");
    PRPG_Seed = 12;
		SRSG_Seed = 5;
		MISR_Seed = 13;
		SISA_Seed = 24;
		
		clk = 0;
    cfgFile = $fopen("Configuration.txt", "r");
    i = 0;
    
    while (!$feof(cfgFile)) begin
      i = i + 1;
      status = $fscanf(cfgFile, "%h %h %h %h %h %h %h %d\n", PRPG_Poly, SRSG_Poly, MISR_Poly, SISA_Poly, PRPG_Seed, SRSG_Seed, MISR_Seed, SISA_Seed);
      masterRst = 1'b1; #1 masterRst = 1'b0;
      @(posedge done);
      $fwrite(sigFile, "%h %h\n", MISR_Out, SISA_Out);
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

      status = $fscanf(sigFile, "%h %h\n", Golden_MISR_Out, Golden_SISA_Out);
      // $fclose(sigFile);
      // Apply Configurations
      status = $fscanf(cfgFile, "%h %h %h %h %h %h %h %d\n", PRPG_Poly, SRSG_Poly, MISR_Poly, SISA_Poly, PRPG_Seed, SRSG_Seed, MISR_Seed, SISA_Seed);
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
        if ({MISR_Out, SISA_Out} != {Golden_MISR_Out,Golden_SISA_Out})
          numOfDetected = numOfDetected + 1;
        else
          UNnumOfDetected = UNnumOfDetected + 1;
          $display("%h ,%h _%h ,%h", Golden_MISR_Out, MISR_Out, Golden_SISA_Out,SISA_Out);

        $RemoveFault(wireName);
      end // "while( !$feof(faultFile))"

      coverage = numOfDetected * 100.0 / numOfFaults;
      $display("F Coverage: %f/%f = %f", numOfDetected, numOfFaults, coverage);
      $fwrite(resultFile, "%h %h %h %h %h %h %h %h %d %d %f\n", PRPG_Poly, SRSG_Poly, MISR_Poly, SISA_Poly, PRPG_Seed, SRSG_Seed, MISR_Seed, SISA_Seed, numOfTstCycl, numOfTstCycl * Shift_Cnt, coverage);
    end // "while( !$feof(cfgFile) )"

    $stop;
  end
endmodule
