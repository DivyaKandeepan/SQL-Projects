select * from nashvilla.dbo.nashville;

--Standardize Date format

----we only want salesdate not time so we added new column as saledateconverted,in that we inserted the converted date of saledate.

Alter table nashville add saledateconverted date;

update nashville set saledateconverted = convert(Date,saledate);

select saledate,saledateconverted from nashvilla.dbo.nashville;

--------------------------------------------------------------------------------------------------------------------------------------------------

--Populate property Address data

--indha query la enna pandrom na propertyaddress null irruka kudadhu but inga data la irruku so epaid anga property address koduvaradhu
--oru oru propertykum oru pracelid irruku so ippo same parcelid irruka innoru data ku property address illa na andha property address idhuku 
--copy panidalam. so idhuku self join use pani endha data ku ellam same parcelid irruku and but onnuthuku address iruku innonuthuku address
--illa nu pakannum adhukapuram ISNULL use pani a.propertyaddress null la irudhuchuna b.property adddress sa anga copy panikonu sollirom
--and dhae mari uniqueid same ma irruka kudadhu and where condiotion a a.propertyaddress null irrukanum nu solli irrukom.

select propertyaddress from nashvilla.dbo.nashville;

select * from nashvilla.dbo.nashville
--where propertyaddress is null
order by parcelid;

select a.parcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,ISNULL(a.PropertyAddress,b.PropertyAddress) 
	from nashvilla.dbo.nashville a join nashvilla.dbo.nashville b
	on a.ParcelID=b.ParcelID and a.uniqueID<>b.uniqueID
	where a.propertyaddress is null;

Update a
set propertyaddress=ISNULL(a.PropertyAddress,b.PropertyAddress)
from nashvilla.dbo.nashville a join nashvilla.dbo.nashville b
	on a.ParcelID=b.ParcelID and a.uniqueID<>b.uniqueID
	where a.propertyaddress is null;
-------------------------------------------------------------------------------------------------------------------------------------------------

--breaking out Address column into Address,City columns

select substring(PropertyAddress,1,charindex(',',PropertyAddress)-1)as Address,
substring(PropertyAddress,charindex(',',PropertyAddress)+1,len(PropertyAddress)) as City
from nashvilla.dbo.nashville

Alter Table nashvilla.dbo.nashville add PropertySplitAddress nvarchar(255);
update nashvilla.dbo.nashville set PropertySplitAddress = substring(PropertyAddress,1,charindex(',',PropertyAddress)-1);

Alter Table nashvilla.dbo.nashville add PropertySplitCity nvarchar(255);
update nashvilla.dbo.nashville set PropertySplitAddress = substring(PropertyAddress,charindex(',',PropertyAddress)+1,len(PropertyAddress));

-- Another ways to split an address(owner Address)

Select PARSENAME(replace(OwnerAddress,',','.'),3),
PARSENAME(replace(OwnerAddress,',','.'),2),
PARSENAME(replace(OwnerAddress,',','.'),1)
from nashvilla.dbo.nashville

Alter table nashvilla.dbo.nashville add OwnerSplitaddress Nvarchar(255);
update nashvilla.dbo.nashville set OwnerSplitaddress=PARSENAME(replace(OwnerAddress,',','.'),3);

Alter table nashvilla.dbo.nashville add OwnerSplitCity Nvarchar(255);
update nashvilla.dbo.nashville set OwnerSplitState=PARSENAME(replace(OwnerAddress,',','.'),2);

Alter table nashvilla.dbo.nashville add OwnerSplitstate Nvarchar(255);
update nashvilla.dbo.nashville set OwnerSplitstate=PARSENAME(replace(OwnerAddress,',','.'),1);

--------------------------------------------------------------------------------------------------------------------------------------------------
--Change Y and N to Yes and No in "Sold as Vacant" field.

Select Distinct(SoldAsVacant),count(SoldAsVacant) From nashvilla.dbo.nashville
group by SoldAsVacant
order by 2

Select SoldAsVacant,CASE When SoldAsVacant='Y'THEN 'Yes'
						 When SoldAsVacant='N'THEN 'No'
						 Else SoldAsVacant
						 END
from nashvilla.dbo.nashville

update nashvilla.dbo.nashville
Set SoldAsVacant=CASE When SoldAsVacant='Y'THEN 'Yes'
						 When SoldAsVacant='N'THEN 'No'
						 Else SoldAsVacant
						 END
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------						 

--Remove Duplicates

With rownums as( select*,
ROW_NUMBER() OVER( PARTITION by ParcelID,
						PropertyAddress,
						SalePrice,
						SaleDate,
						LegalReference
						Order by UniqueID)row_num
from nashvilla.dbo.nashville)
select*from rownums where row_num>1
order by PropertyAddress 

select*from nashvilla.dbo.nashville
----------------------------------------------------------------------------------------------------------------------------------------------------
---Delete unused columns

Alter table nashvilla.dbo.nashville
	drop column OwnerAddress,PropertyAddress,SaleDate;




















































