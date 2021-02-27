/**
 * Created by Ilya Matsuev on 2/26/2021.
 */

public with sharing class CollectionUtils {
    public static Set<Id> getIdFieldFromList(
        List<SObject> sObjects,
        String fieldName
    ) {
        Set<Id> ids = new Set<Id>();
        for (SObject sObj : sObjects) {
            ids.add((Id) sObj.get(fieldName));
        }
        return ids;
    }
}
