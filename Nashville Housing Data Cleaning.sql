
/* 

Cleaning Data in SQL Queries

*/

SELECT * FROM Project.dbo.NashvilleHousing

---------------------------------------------------------------------------------------------------------------------------
-- Standardize Date Format


SELECT SaleDate FROM NashvilleHousing

SELECT SalesDateConverted, CONVERT(DATE,SaleDate) As SaleDate 
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
ADD SalesDateConverted DATE

UPDATE NashvilleHousing
SET SalesDateConverted =CONVERT(DATE,SaleDate)


---------------------------------------------------------------------------------------------------------------------------

--- Populate Property Address data

SELECT *
FROM NashvilleHousing
---WHERE PropertyAddress IS NULL
ORDER BY ParcelID


---Join the table it self cause ParcelId is same for same PropertyAddress 
--- And based on Different Unique Id we check If there is NULL or NOT 
SELECT a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM NashvilleHousing a
 JOIN NashvilleHousing b
	ON a.ParcelID = b.ParcelID 
	AND a.UniqueID <> b.UniqueID 
WHERE a.PropertyAddress IS NULL


UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM NashvilleHousing a
 JOIN NashvilleHousing b
	ON a.ParcelID = b.ParcelID 
	AND a.UniqueID <> b.UniqueID 
WHERE a.PropertyAddress IS NULL

---------------------------------------------------------------------------------------------------------------------------

--Breaking down the Address into Individual Cloumns (Address, City , State)

SELECT PropertyAddress 
FROM NashvilleHousing

SELECT 
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) AS Address,
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) AS Address
FROM NashvilleHousing



ALTER TABLE NashvilleHousing
ADD PropertySplitAddress nvarchar(255)

UPDATE NashvilleHousing
SET PropertySplitAddress =SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)

ALTER TABLE NashvilleHousing
ADD PropertySplitCity nvarchar(255)

UPDATE NashvilleHousing
SET PropertySplitCity =SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))

SELECT * FROM NashvilleHousing




--another way to separata names delimated by specify values using PARSENAME and REPLACE

SELECT OwnerAddress FROM NashvilleHousing

SELECT
PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM NashvilleHousing



ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress nvarchar(255)

UPDATE NashvilleHousing
SET OwnerSplitAddress =PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity nvarchar(255)

UPDATE NashvilleHousing
SET OwnerSplitCity =PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE NashvilleHousing
ADD OwnerSplitState nvarchar(255)

UPDATE NashvilleHousing
SET OwnerSplitState =PARSENAME(REPLACE(OwnerAddress,',','.'),1)

---------------------------------------------------------------------------------------------------------------------------

-----Change Y and N to Yes and No In "Sold as vacant" field


SELECT DISTINCT(SoldAsVacant) ,COUNT(SoldAsVacant)
FROM NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2


SELECT SoldAsVacant,
	CASE
		WHEN SoldAsVacant =  'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
	END
FROM NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant =
	CASE
		WHEN SoldAsVacant =  'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
	END


---------------------------------------------------------------------------------------------------------------------------

----Remove Duplicates

----Identifying Duplicates
WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	
	PARTITION BY  ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY UniqueId
	) Row_Num
FROM NashvilleHousing
)
SELECT *
FROM RowNumCTE
WHERE Row_Num > 1 
ORDER BY PropertyAddress

--deleting duplicates

WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	
	PARTITION BY  ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY UniqueId
	) Row_Num
FROM NashvilleHousing
)
DELETE
FROM RowNumCTE
WHERE Row_Num > 1 

-------------------------------------------------------------------------------------------------------------------------

---Deleting Unused Column

Select * from NashvilleHousing

ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress,TaxDistrict,PropertyAddress

ALTER TABLE NashvilleHousing
DROP COLUMN SaleDate

-------------------------------------------------------------------------------------------------------------------------
--CLeaned Data

SELECT * FROM NashvilleHousing
ORDER BY [UniqueID ]