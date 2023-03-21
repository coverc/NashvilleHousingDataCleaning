SELECT *
FROM PortfolioProject..NashvilleHousing;

-- Remove Timestamp from Date
SELECT SaleDateConverted, CONVERT(DATE, SaleDate)
FROM PortfolioProject..NashvilleHousing;

UPDATE NashvilleHousing SET SaleDate = CONVERT(DATE, SaleDate);
--Above Method was not working, trying method below
ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

UPDATE NashvilleHousing SET SaleDateConverted = CONVERT(DATE, SaleDate);

--Populate property addresses that are empty
SELECT *
FROM PortfolioProject..NashvilleHousing
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID;

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL;

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL;

--Seperating address into individual columns

SELECT PropertyAddress
FROM PortfolioProject..NashvilleHousing;

SELECT SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) AS StreetAddress, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+2, LEN(PropertyAddress)) AS City
FROM PortfolioProject..NashvilleHousing;


--Add column for property street address
ALTER TABLE NashvilleHousing
Add PropertyStreetAddress nvarchar(255);

UPDATE NashvilleHousing 
SET PropertyStreetAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1);

--Add column for property city
ALTER TABLE NashvilleHousing
Add PropertyCity nvarchar(255);

UPDATE NashvilleHousing 
SET PropertyCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+2, LEN(PropertyAddress));

SELECT *
FROM PortfolioProject..NashvilleHousing;

--Separating Owner Address into Street, city, and state

SELECT ownerAddress
FROM PortfolioProject..NashvilleHousing;

SELECT PARSENAME(REPLACE(OwnerAddress,',', '.'), 3) AS OwnerStreetAddress, PARSENAME(REPLACE(OwnerAddress,',', '.'), 2) AS OwnerCity, PARSENAME(REPLACE(OwnerAddress,',', '.'), 3) AS OwnerState
FROM PortfolioProject..NashvilleHousing;

--Add Owner Street Address Column
ALTER TABLE NashvilleHousing
Add OwnerStreetAddress nvarchar(255);

UPDATE NashvilleHousing
SET OwnerStreetAddress = PARSENAME(REPLACE(OwnerAddress,',', '.'), 3)

--Add Owner City Column
ALTER TABLE NashvilleHousing
Add OwnerCity nvarchar(255);

UPDATE NashvilleHousing
SET OwnerCity = PARSENAME(REPLACE(OwnerAddress,',', '.'), 2)

--Add Owner State Column
ALTER TABLE NashvilleHousing
Add OwnerState nvarchar(255);

UPDATE NashvilleHousing
SET OwnerState = PARSENAME(REPLACE(OwnerAddress,',', '.'), 1)


-- Y and N -> Yes and No in SoldAsVacant
SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProject..NashvilleHousing
GROUP BY SoldAsVacant;

UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
						WHEN SoldAsVacant = 'N' THEN 'No'
						ELSE SoldAsVacant
					END



--Remove Duplicate Data
WITH RowNumCTE AS(
SELECT *, ROW_NUMBER() OVER(
						PARTITION BY ParcelID,
									 PropertyAddress,
									 SalePrice,
									 SaleDate,
									 LegalReference
									 ORDER BY UniqueID) AS RowNum
FROM PortfolioProject..NashvilleHousing
)
SELECT *
FROM RowNumCTE
WHERE RowNum>1;


--Delete Unnecessary Columns
--PropertyAddress, SaleDate, OwnerAddress, TaxDistrict

ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN PropertyAddress, SaleDate, OwnerAddress, TaxDistrict

SELECT * 
FROM PortfolioProject..NashvilleHousing;