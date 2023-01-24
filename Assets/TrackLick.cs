using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TrackLick : MonoBehaviour
{
    public SkinnedMeshRenderer candleStem;
    public GameObject StartPoint;
    public GameObject EndPoint;
    public GameObject MidPoint;
    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    void Test()
    {
        var value = (((StartPoint.transform.localPosition.y - EndPoint.transform.localPosition.y) / 100) * candleStem.GetBlendShapeWeight(0));
        MidPoint.transform.localPosition = new Vector3(0, value, 0);
    }
}
