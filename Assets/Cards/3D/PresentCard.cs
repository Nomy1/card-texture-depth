using UnityEngine;

public class PresentCard : MonoBehaviour
{
    [SerializeField, Range(0f, 10f)] float playSpeed;
    [SerializeField, Range(0f, 40f)] float rotationRange;
    
    void Update()
    {
        float targetRotation = Mathf.Sin(Time.time * playSpeed) * rotationRange;
        transform.localRotation = Quaternion.AngleAxis(targetRotation, transform.up);
    }
}
