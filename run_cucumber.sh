echo ----------------------------------------
echo -------- Run Cucumber Tests ------------
echo ----------------------------------------
cucumber
echo ----------------------------------------
echo -------- Run Rspec Tests ---------------
echo ----------------------------------------
rspec
echo ----------------------------------------
echo -------- Re-populate database ----------
echo ----------------------------------------
rake db:seed
echo ----------------------------------------
echo -------- Re-populate ir data -----------
echo ----------------------------------------
curl -X POST http://localhost:9091/tasks/ir-repopulate
echo ----------------------------------------
echo -------- Re-Index Elastic Search -------
echo ----------------------------------------
cd ../waste-exemplar-services/bin
sh reIndex.sh