def copyAttributes(fromFeature, toFeature):
    for i in range(fromFeature.GetFieldCount()):
        fieldName = fromFeature.GetFieldDefnRef(i).GetName()
        toFeature.SetField(fieldName,fromFeature.GetField(fieldName))
