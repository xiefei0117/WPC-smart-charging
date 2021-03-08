/*********************************************
 * OPL 12.9.0.0 Model
 * Author: ORNL_Admin
 * Creation Date: May 4, 2020 at 11:31:05 AM
 *********************************************/
range ParkingLots = 1..100;
range ElectricVehicles = 1..100;
{int} TimePeriods = {6,7,8,9,10,11,12,13,14,15,16,17,18,19};
{int} TimePeriodsButLast = {6,7,8,9,10,11,12,13,14,15,16,17,18};
range Levels = 1..3;
float demandChargeRate = ...;
float ChargingDemand[ElectricVehicles] = ...;
float PeriodLength = ...;
float ChargingEfficiency [Levels] = ...;
float Price [TimePeriods] = ...;
float Price2 [TimePeriods] = ...;
float InstallationCost [Levels] = ...;
float MaxPower[Levels] = ...;
int VehicleStatus [ElectricVehicles][TimePeriods] =...;

dvar boolean X[ParkingLots][Levels];
dvar float+ Y[ParkingLots][ElectricVehicles][TimePeriods][Levels];
dvar boolean Z[ParkingLots][ElectricVehicles][TimePeriods];
dvar float+ W;

minimize
  sum(j in ElectricVehicles)(ChargingDemand[j] - sum(i in ParkingLots, t in TimePeriods, k in Levels)ChargingEfficiency[k]*Y[i,j,t,k]*PeriodLength);
    

subject to {

  //for each parking lot, decision about installing which level charger
  WhichLevel:
	forall(i in ParkingLots)
	  sum (k in Levels) X[i][k] <=1;
  
  //assign EVs to electrified parking lots	
  WhereToCharge:
    forall(i in ParkingLots, j in ElectricVehicles, t in TimePeriods, k in Levels)
      Y[i][j][t][k] <= X[i][k];

  ParkThenCharge:
    forall(i in ParkingLots, j in ElectricVehicles, t in TimePeriods, k in Levels)
      Y[i][j][t][k] <= Z[i][j][t];  
  
  Parking:
    forall(j in ElectricVehicles, t in TimePeriods)
      sum(i in ParkingLots)Z[i][j][t] == VehicleStatus[j][t];

  OneLotOneVehicleOneTime:
    forall(i in ParkingLots, t in TimePeriods)
      sum(j in ElectricVehicles)Z[i][j][t]<=1;  

  Budget:
    1000+0.1627*sum(i in ParkingLots, k in Levels)InstallationCost[k]*X[i][k] + 
    	130*sum(i in ParkingLots, j in ElectricVehicles, t in TimePeriods, k in Levels)MaxPower[k]*Y[i][j][t][k]*PeriodLength*Price[t] +
    	130*sum(i in ParkingLots, j in ElectricVehicles, t in TimePeriods, k in Levels)MaxPower[k]*Y[i][j][t][k]*PeriodLength*Price2[t] +
    	12*demandChargeRate*W<= 40000;

  demand:
    forall(j in ElectricVehicles)
      sum(i in ParkingLots, t in TimePeriods, k in Levels)ChargingEfficiency[k]*Y[i][j][t][k]*PeriodLength <= ChargingDemand[j];

  ParkingLogic:
    forall(i in ParkingLots, j in ElectricVehicles, t in TimePeriodsButLast)
      Z[i][j][t] <= Z[i][j][t+1] + (1-VehicleStatus[j][t+1]);
  
  RangeOnY:
    forall(i in ParkingLots, j in ElectricVehicles, t in TimePeriods, k in Levels)
      Y[i][j][t][k] <= 1;
  
  DemandCharge:
    forall(t in TimePeriods)
      sum(i in ParkingLots, j in ElectricVehicles, k in Levels)MaxPower[k]*Y[i][j][t][k]<=W;

}

execute{
		//cplex.prepass = 0;

        //cplex.tilim = 10;
}
execute{
  var f = new IloOplOutputFile("results_varied_1dollars_demand_charge.csv");
  //print X
  f.writeln("outputs for X:");
  f.writeln("parkingLot",",","Level1",",","Level2L",",","Level2M");
  for (i in ParkingLots) {
    f.write(i,", ");           
    for (k in Levels) {
      f.write(X[i][k],", ");    
    }    
    f.write("\\\n");
  }
  
  //print Y
  f.writeln();
  f.writeln("outputs for Y:");
  f.writeln("Level 1:");
  f.write("ParkingLots",", ", "ElectricVehicles",", ");
  for (t in TimePeriods) {
    f.write(t, ", ");  
  }
  f.write("\\\n");
  for (i in ParkingLots) {
    for (j in ElectricVehicles) {
      f.write(i, ", ", j, ", ");
      for (t in TimePeriods) {           
        f.write(Y[i][j][t][1], ", ");      
      }
      f.write("\\\n");    
    }  
  }
  f.writeln();
  
  f.writeln("Level 2L:");
  f.write("ParkingLots",", ", "ElectricVehicles",", ");
  for (t in TimePeriods) {
    f.write(t, ", ");  
  }
  f.write("\\\n");
  for (i in ParkingLots) {
    for (j in ElectricVehicles) {
      f.write(i, ", ", j, ", ");
      for (t in TimePeriods) {           
        f.write(Y[i][j][t][2], ", ");      
      }
      f.write("\\\n");    
    }  
  }
  f.writeln();
  
  f.writeln("Level 2M:");
  f.write("ParkingLots",", ", "ElectricVehicles",", ");
  for (t in TimePeriods) {
    f.write(t, ", ");  
  }
  f.write("\\\n");
  for (i in ParkingLots) {
    for (j in ElectricVehicles) {
      f.write(i, ", ", j, ", ");
      for (t in TimePeriods) {           
        f.write(Y[i][j][t][3], ", ");      
      }
      f.write("\\\n");    
    }  
  }
  f.writeln();
  
  //print Z
  f.writeln("outputs for Z:");
  f.write("ParkingLots",", ", "ElectricVehicles",", ");
  for (t in TimePeriods) {
    f.write(t, ", ");  
  }
  f.write("\\\n");
  for (i in ParkingLots) {
    for (j in ElectricVehicles) {
      f.write(i, ", ", j, ", ");
      for (t in TimePeriods) {
        f.write(Z[i][j][t], ", ");      
      }
      f.write("\\\n");    
    }  
  }
}

