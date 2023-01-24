using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Highlight : MonoBehaviour
{
    public Mesh mesh;
    public Material material;
    // Start is called before the first frame update
    void Start()
    {
        mesh = gameObject.GetComponent<SkinnedMeshRenderer>().sharedMesh;
        material = gameObject.GetComponent<SkinnedMeshRenderer>().material;
    }

    // Update is called once per frame
    void Update()
    {
        Graphics.DrawMesh(mesh, Vector3.zero, Quaternion.identity, material, 0);

    }
}
