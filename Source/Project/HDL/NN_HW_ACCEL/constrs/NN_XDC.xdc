##MATRIX - Pmod Header JD                                                                                                                  
set_property -dict { PACKAGE_PIN T14   IOSTANDARD LVCMOS33     } [get_ports { po_h_data[0] }]; #IO_L5P_T0_34 Sch=jd_p[1]                  
set_property -dict { PACKAGE_PIN T15   IOSTANDARD LVCMOS33     } [get_ports { po_h_data[1] }]; #IO_L5N_T0_34 Sch=jd_n[1]				 
set_property -dict { PACKAGE_PIN P14   IOSTANDARD LVCMOS33     } [get_ports { po_h_data[2] }]; #IO_L6P_T0_34 Sch=jd_p[2]                  
set_property -dict { PACKAGE_PIN R14   IOSTANDARD LVCMOS33     } [get_ports { po_h_data[3] }]; #IO_L6N_T0_VREF_34 Sch=jd_n[2]             
set_property -dict { PACKAGE_PIN U14   IOSTANDARD LVCMOS33     } [get_ports { po_h_data[4] }]; #IO_L11P_T1_SRCC_34 Sch=jd_p[3]            
set_property -dict { PACKAGE_PIN U15   IOSTANDARD LVCMOS33     } [get_ports { po_h_data[5] }]; #IO_L11N_T1_SRCC_34 Sch=jd_n[3]            
set_property -dict { PACKAGE_PIN V17   IOSTANDARD LVCMOS33     } [get_ports { po_h_data[6] }]; #IO_L21P_T3_DQS_34 Sch=jd_p[4]             
set_property -dict { PACKAGE_PIN V18   IOSTANDARD LVCMOS33     } [get_ports { po_h_data[7] }]; #IO_L21N_T3_DQS_34 Sch=jd_n[4]             
##MATRIX - Pmod Header JC                                                                                                                  
set_property -dict { PACKAGE_PIN V15   IOSTANDARD LVCMOS33     } [get_ports { po_v_data[0] }]; #IO_L10P_T1_34 Sch=jc_p[1]   			 
set_property -dict { PACKAGE_PIN W15   IOSTANDARD LVCMOS33     } [get_ports { po_v_data[1] }]; #IO_L10N_T1_34 Sch=jc_n[1]		     
set_property -dict { PACKAGE_PIN T11   IOSTANDARD LVCMOS33     } [get_ports { po_v_data[2] }]; #IO_L1P_T0_34 Sch=jc_p[2]              
set_property -dict { PACKAGE_PIN T10   IOSTANDARD LVCMOS33     } [get_ports { po_v_data[3] }]; #IO_L1N_T0_34 Sch=jc_n[2]              
set_property -dict { PACKAGE_PIN W14   IOSTANDARD LVCMOS33     } [get_ports { po_v_data[4] }]; #IO_L8P_T1_34 Sch=jc_p[3]              
set_property -dict { PACKAGE_PIN Y14   IOSTANDARD LVCMOS33     } [get_ports { po_v_data[5] }]; #IO_L8N_T1_34 Sch=jc_n[3]              
set_property -dict { PACKAGE_PIN T12   IOSTANDARD LVCMOS33     } [get_ports { po_v_data[6] }]; #IO_L2P_T0_34 Sch=jc_p[4]              
set_property -dict { PACKAGE_PIN U12   IOSTANDARD LVCMOS33     } [get_ports { po_v_data[7] }]; #IO_L2N_T0_34 Sch=jc_n[4]   
#UART
set_property -dict {PACKAGE_PIN  V12 IOSTANDARD LVCMOS33} [get_ports pi_RX_0]
set_property -dict {PACKAGE_PIN  W16 IOSTANDARD LVCMOS33} [get_ports po_TX_0]
#NOT USED
#set_property -dict {PACKAGE_PIN  J15 IOSTANDARD LVCMOS33} [get_ports gpio_rtl]
#BUTTONS
set_property -dict { PACKAGE_PIN K18   IOSTANDARD LVCMOS33 } [get_ports btns_4bits[0]]
set_property -dict { PACKAGE_PIN P16   IOSTANDARD LVCMOS33 } [get_ports btns_4bits[1]]
set_property -dict { PACKAGE_PIN K19   IOSTANDARD LVCMOS33 } [get_ports btns_4bits[2]]
set_property -dict { PACKAGE_PIN Y16   IOSTANDARD LVCMOS33 } [get_ports btns_4bits[3]]
