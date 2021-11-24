
--Cleaning Data in SQL Queries

Select *
From [Portfolio Project].dbo.NashvilleHousing


--Standardize Date Format

Select SaleDateConverted, CONVERT(Date,SaleDate)
From [Portfolio Project].dbo.NashvilleHousing

Update NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)

ALTER Table NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)


--Populate Proeprty Address Data

Select PropertyAddress
From [Portfolio Project].dbo.NashvilleHousing
Where PropertyAddress is null

Select *
From [Portfolio Project].dbo.NashvilleHousing
--Where PropertyAddress is null
Order by ParcelID


--Replaces Property addresses
Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.propertyaddress, b.PropertyAddress)
From [Portfolio Project].dbo.NashvilleHousing a
	JOIN [Portfolio Project].dbo.NashvilleHousing b
	ON A.ParcelID = b.ParcelID
	And a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null
	
--Update Table

Update a
SET PropertyAddress = ISNULL(a.propertyaddress, b.PropertyAddress)
From [Portfolio Project].dbo.NashvilleHousing a
	JOIN [Portfolio Project].dbo.NashvilleHousing b
	ON A.ParcelID = b.ParcelID
	And a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

--Breaking out Address Into Individual Columns (Address, City, State)

Select PropertyAddress
From [Portfolio Project].dbo.NashvilleHousing
--Where PropertyAddress is null
--Order by ParcelID

--Getting rid of comma add -1 in CHARINDEX
--Previous
--SELECT
--SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)) as Address 
--From [Portfolio Project].dbo.NashvilleHousing

--After

--SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address 
--From [Portfolio Project].dbo.NashvilleHousing

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address 
,SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as Address 
From [Portfolio Project].dbo.NashvilleHousing

ALTER Table NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

--

ALTER Table NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

--

Select *
From [Portfolio Project].dbo.NashvilleHousing

Select OwnerAddress
From [Portfolio Project].dbo.NashvilleHousing

--Parsename looks for (.)
Select 
PARSENAME (Replace(OwnerAddress, ',', '.'), 3) as Address
,PARSENAME (Replace(OwnerAddress, ',', '.'), 2) as City
,PARSENAME (Replace(OwnerAddress, ',', '.'), 1) as State
From [Portfolio Project].dbo.NashvilleHousing

ALTER Table NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME (Replace(OwnerAddress, ',', '.'), 3) 


ALTER Table NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME (Replace(OwnerAddress, ',', '.'), 2)

ALTER Table NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME (Replace(OwnerAddress, ',', '.'), 1)

Select *
From [Portfolio Project].dbo.NashvilleHousing

--Change Y and N to Yes and No in "sold as Vacabt" field

Select distinct(SoldAsVacant), COUNT(SoldAsVacant)
From [Portfolio Project].dbo.NashvilleHousing
Group by SoldAsVacant
Order by 2

Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' Then 'Yes'
	When SoldAsVacant = 'N' Then 'No'
		Else SoldAsVacant
		End
From [Portfolio Project].dbo.NashvilleHousing

Update NashvilleHousing
Set SoldAsVacant = CASE When SoldAsVacant = 'Y' Then 'Yes'
	When SoldAsVacant = 'N' Then 'No'
		Else SoldAsVacant
		End
From [Portfolio Project].dbo.NashvilleHousing

--Checking if Update System worked 

Select distinct(SoldAsVacant), COUNT(SoldAsVacant)
From [Portfolio Project].dbo.NashvilleHousing
Group by SoldAsVacant
Order by 2

--Remove Duplicates
WITH RowNumCTE AS(
Select *,

Row_number() Over (
Partition by ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference

Order by UniqueID 
) row_num

From [Portfolio Project].dbo.NashvilleHousing
--Order by parcelID
)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress

----Use Delete 
----Select * -Change this to delete and remove Order 
--From RowNumCTE
--Where row_num > 1
--Order by PropertyAddress
--Delete
--From RowNumCTE
--Where row_num > 1
--Order by PropertyAddress




--Delete Unused Columns 
select *
From [Portfolio Project].dbo.NashvilleHousing

ALTER Table [Portfolio Project].dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER Table [Portfolio Project].dbo.NashvilleHousing
DROP COLUMN SaleDate