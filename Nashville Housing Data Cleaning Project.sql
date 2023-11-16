/*

Cleaning Data in SQL Queries

*/


Select *
From PortfolioProject.dbo.NashvilleHousing

--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format

Select SaleDate2, CONVERT(DATE,SaleDate)
From PortfolioProject.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
ADD SaleDate2 Date;

UPDATE NashvilleHousing
SET SaleDate2 = CONVERT(DATE,SaleDate)


 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data


SELECT *
From PortfolioProject.dbo.NashvilleHousing
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID

SELECT T1.[UniqueID ],T1.ParcelID,T1.PropertyAddress,T2.[UniqueID ],T2.ParcelID,T2.PropertyAddress,ISNULL(T1.PropertyAddress,T2.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing T1
JOIN PortfolioProject.dbo.NashvilleHousing T2
ON T1.ParcelID = T2.ParcelID AND T1.[UniqueID ] <> T2.[UniqueID ]
WHERE T1.PropertyAddress IS NULL

UPDATE T1
SET PropertyAddress = ISNULL(T1.PropertyAddress,T2.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing T1
JOIN PortfolioProject.dbo.NashvilleHousing T2
ON T1.ParcelID = T2.ParcelID AND T1.[UniqueID ] <> T2.[UniqueID ]
WHERE T1.PropertyAddress IS NULL

--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

Select PropertyAddress
From PortfolioProject.dbo.NashvilleHousing

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) as Address
From PortfolioProject.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress nvarchar(255);

update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1)

ALTER TABLE NashvilleHousing
ADD PropertySplitCity nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))

SELECT
SUBSTRING(OwnerAddress, 1, CHARINDEX(',',PropertyAddress)-1) as Address
From PortfolioProject.dbo.NashvilleHousing

Select OwnerAddress
From PortfolioProject.dbo.NashvilleHousing

Select PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
From PortfolioProject.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE NashvilleHousing
ADD OwnerSplitState nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field

Select DISTINCT SoldAsVacant, COUNT(SoldAsVacant)
From PortfolioProject.dbo.NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

Select SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'  
WHEN SoldAsVacant = 'N' THEN 'No' 
ELSE SoldAsVacant END
From PortfolioProject.dbo.NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'  
WHEN SoldAsVacant = 'N' THEN 'No' 
ELSE SoldAsVacant END
From PortfolioProject.dbo.NashvilleHousing

-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

WITH RowNumCTE as (Select *,
ROW_NUMBER() OVER(PARTITION BY ParcelID,PropertyAddress,Saleprice,SaleDate,LegalReference ORDER BY UniqueID) row_num
From PortfolioProject.dbo.NashvilleHousing)

SELECT *
from RowNumCTE
where row_num>1

---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

Select *
From PortfolioProject.dbo.NashvilleHousing

ALTER table NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress,Saledate