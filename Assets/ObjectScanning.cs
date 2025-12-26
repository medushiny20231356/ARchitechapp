using UnityEngine;
using UnityEngine.XR.ARFoundation;
using System.Collections.Generic;
using System.IO;


public class ObjectScanning : MonoBehaviour
{
    public ARMeshManager meshManager; //Assign in inspector
    public Collider scanVolume;


    private List<MeshFilter> scannedMeshes = new List<MeshFilter>();

    [ContextMenu("Scan and save the object")]
    public void ScanAndSave(){
        scannedMeshes.Clear();

        //filter meshes inside the bounding box
        foreach (var meshFilter in meshManager.meshes){
            if(scanVolume.bounds.Contains(meshFilter.transform.position)){
                scannedMeshes.Add(meshFilter);
            }
        }
        if(scannedMeshes.Count == 0){
            Debug.LogWarning("No meshes found insoide the scan volume");
            return;
        }


        CombineInstance[] combine= new CombineInstance[scannedMeshes.Count];
        for(int i =0; i<scannedMeshes.Count; i++){
            combine[i].mesh = scannedMeshes[i].sharedMesh;
            combine[i].transform= scannedMeshes[i].transform.localToWorldMatrix;

        }
        Mesh combinedMesh = new Mesh();
        combinedMesh.CombineMeshes(combine);

        //save as .obj
        string filePath = Path.Combine(Application.persistentDataPath,"ScannedObject.obj");
        Debug.Log("OBJ saved at: "+filePath);
        MeshToFile(combinedMesh, filePath);

        Debug.Log("Object saved to : "+filePath);
    } 
    void MeshToFile(Mesh mesh, string filePath)
{
    using (StreamWriter sw = new StreamWriter(filePath))
    {
        sw.Write(MeshToString(mesh));
    }
}

string MeshToString(Mesh mesh)
{
    System.Text.StringBuilder sb = new System.Text.StringBuilder();

    // Vertices
    foreach (Vector3 v in mesh.vertices)
        sb.AppendLine($"v {v.x} {v.y} {v.z}");

    // Normals
    foreach (Vector3 n in mesh.normals)
        sb.AppendLine($"vn {n.x} {n.y} {n.z}");

    // UVs
    foreach (Vector2 uv in mesh.uv)
        sb.AppendLine($"vt {uv.x} {uv.y}");

    // Faces
    for (int i = 0; i < mesh.subMeshCount; i++)
    {
        int[] triangles = mesh.GetTriangles(i);
        for (int t = 0; t < triangles.Length; t += 3)
        {
            int a = triangles[t] + 1;
            int b = triangles[t + 1] + 1;
            int c = triangles[t + 2] + 1;
            sb.AppendLine($"f {a}/{a}/{a} {b}/{b}/{b} {c}/{c}/{c}");
        }
    }

    return sb.ToString();
}

}

