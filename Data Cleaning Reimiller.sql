-- Cleaning Data in SQL Queries

-- Standardized Date Format


Select SaleDateConverted, CONVERT(Date,SaleDate)
FROM PortfolioProject.dbo.NashvilleHousing

Update NashvilleHousing
set SaleDate = CONVERT(Date,SaleDate)

ALTER TABLE NashvilleHousing 
ADD SaleDateConverted Date;

Update NashvilleHousing
set SaleDateConverted = CONVERT(Date,SaleDate)




-- Populate Property Adress Data

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing
WHERE PropertyAddress  is null
ORDER BY ParcelID



SELECT A.ParcelID, A.PropertyAddress, B.ParcelID, B.PropertyAddress,ISNULL(A.PropertyAddress,B.PropertyAddress) 
FROM PortfolioProject.dbo.NashvilleHousing as A
JOIN PortfolioProject.dbo.NashvilleHousing as B
	on A.ParcelID =B.ParcelID
	and a.[UniqueID ] <> B.[UniqueID ]
where a.PropertyAddress is null

Update A
set A.PropertyAddress = ISNULL(A.PropertyAddress,B.PropertyAddress) 
FROM PortfolioProject.dbo.NashvilleHousing as A
JOIN PortfolioProject.dbo.NashvilleHousing as B
	on A.ParcelID =B.ParcelID
	and a.[UniqueID ] <> B.[UniqueID ]
where a.PropertyAddress is null



SELECT *
FROM PortfolioProject.dbo.NashvilleHousing
ORDER BY ParcelID


-- Breaking Out Address into Individual Columns (Address,City,State)



SELECT PortfolioProject.dbo.NashvilleHousing.PropertyAddress
FROM PortfolioProject.dbo.NashvilleHousing


SELECT 
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress) - 1 ) as Address,
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress) + 1 ,LEN(PropertyAddress)) as Address
FROM PortfolioProject.dbo.NashvilleHousing


ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ADD PropertySplitAddress NVARCHAR(255),
PropertySplitCity NVARCHAR(255);

Update PortfolioProject.dbo.NashvilleHousing
set PropertySplitAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress) - 1 ),
PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress) + 1 ,LEN(PropertyAddress))


SELECT OwnerAddress
FROM PortfolioProject.dbo.NashvilleHousing



SELECT
PARSENAME(REPLACE(OwnerAddress,',','.'),3) AS Address,
PARSENAME(REPLACE(OwnerAddress,',','.'),2) AS City,
PARSENAME(REPLACE(OwnerAddress,',','.'),1) AS State
FROM PortfolioProject.dbo.NashvilleHousing

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ADD OwnerSplitAddress NVARCHAR(255),
OwnerSplitCity NVARCHAR(255),
OwnerSplitState NVARCHAR(255);

Update PortfolioProject.dbo.NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.') , 3),
OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2),
OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1);


SELECT *
FROM PortfolioProject.dbo.NashvilleHousing


-- Change Y and N to Yes and No in "Sold as Vacant" Field

SELECT DISTINCT	(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProject.dbo.NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2


UPDATE NashvilleHousing
SET	 SoldAsVacant = CASE WHEN SoldAsVacant ='Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END

SELECT SoldAsVacant,
CASE WHEN SoldAsVacant ='Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END
FROM PortfolioProject.dbo.NashvilleHousing


-- REMOVE DUPLICATES

WITH RowNumCTE AS(
SELECT * ,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
			PropertyAddress,
			SalePrice,
			SaleDate,
			LegalReference
			ORDER BY
				UniqueID
				) as row_num
FROM PortfolioProject.dbo.NashvilleHousing


)
Delete
From RowNumCTE
where row_num > 1




-- Delete Unused Columns


ALTER TABLE PortfolioProject.DBO.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, ProprertyAddress, SaleDate


