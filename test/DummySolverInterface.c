#include <assert.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

double *fake_read_write_buffer;
const int SIZE = 6;
int fake_dimensions;
const char *fake_mesh_name;
int *fake_ids;
int n_fake_vertices;
const char *fake_data_name;
double *fake_bounding_box;
double *fake_coordinates;

void precicec_createParticipant_withCommunicator(const char *participantName,
                                                 const char *configurationFileName,
                                                 int solverProcessIndex,
                                                 int solverProcessSize,
                                                 void *communicator)
{
    fake_dimensions = 3;
    fake_read_write_buffer = malloc(SIZE * fake_dimensions * sizeof(double));
    fake_mesh_name = "FakeMesh";
    fake_data_name = "";
    fake_data_name = "FakeData";
    n_fake_vertices = 3;
    fake_ids = malloc(n_fake_vertices * sizeof(int));
    fake_bounding_box = malloc(fake_dimensions * 2 * sizeof(double));
    fake_coordinates = malloc(n_fake_vertices * fake_dimensions * sizeof(double));
    fake_ids = malloc(n_fake_vertices * sizeof(int));
    for (int i = 0; i < n_fake_vertices; i++)
    {
        fake_ids[i] = i;
    }
    fake_bounding_box = malloc(fake_dimensions * 2 * sizeof(double));
    for (int i = 0; i < fake_dimensions * 2; i++)
    {
        fake_bounding_box[i] = i;
    }
    fake_coordinates = malloc(n_fake_vertices * fake_dimensions * sizeof(double));
    for (int i = 0; i < n_fake_vertices * fake_dimensions; i++)
    {
        fake_coordinates[i] = i;
    }
}

void precicec_createParticipant(const char *participantName,
                                const char *configurationFileName,
                                int solverProcessIndex,
                                int solverProcessSize)
{
    fake_dimensions = 3;
    fake_read_write_buffer = malloc(SIZE * fake_dimensions * sizeof(double));
    fake_mesh_name = "FakeMesh";
    fake_data_name = "FakeData";
    n_fake_vertices = 3;
    fake_ids = malloc(n_fake_vertices * sizeof(int));
    for (int i = 0; i < n_fake_vertices; i++)
    {
        fake_ids[i] = i;
    }
    fake_bounding_box = malloc(fake_dimensions * 2 * sizeof(double));
    for (int i = 0; i < fake_dimensions * 2; i++)
    {
        fake_bounding_box[i] = i;
    }
    fake_coordinates = malloc(n_fake_vertices * fake_dimensions * sizeof(double));
    for (int i = 0; i < n_fake_vertices * fake_dimensions; i++)
    {
        fake_coordinates[i] = i;
    }
}
void precicec_initialize()
{
}

void precicec_advance(double computedTimeStepSize)
{
}

void precicec_finalize()
{
    // print some output to check if the library is called
    printf("Finalizing solver interface");
}

int precicec_getMeshDimensions(const char *meshName)
{
    return fake_dimensions;
}

int precicec_getDataDimensions(const char *meshName, const char *dataName)
{
    return fake_dimensions;
}

int precicec_isCouplingOngoing()
{
    return 0;
}

int precicec_isTimeWindowComplete()
{
    return 0;
}

double precicec_getMaxTimeStepSize()
{
    return 1.0;
}

int precicec_requiresInitialData()
{
    return 0;
}

int precicec_requiresWritingCheckpoint()
{
    return 0;
}

int precicec_requiresReadingCheckpoint()
{
    return 0;
}

int precicec_hasMesh(const char *meshName)
{
    return 0;
}

int precicec_hasData(const char *meshName, const char *dataName)
{
    return 0;
}

int precicec_requiresMeshConnectivityFor(const char *meshName)
{
    return 0;
}

int precicec_setMeshVertex(const char *meshName, const double *position)
{
    return 0;
}

void precicec_setMeshVertices(const char *meshName, int size, const double *positions, int *ids)
{
    assert(size == n_fake_vertices);
    for (int i = 0; i < size; i++)
    {
        ids[i] = fake_ids[i];
    }
}

int precicec_getMeshVertexSize(const char *meshName)
{
    return n_fake_vertices;
}

void precicec_setMeshEdge(const char *meshName, int firstVertexID, int secondVertexID)
{
}

void precicec_setMeshEdges(
    const char *meshName,
    int size,
    const int *vertices)
{
}

void precicec_setMeshTriangle(const char *meshName, int firstVertexID, int secondVertexID, int thirdVertexID)
{
}

void precicec_setMeshTriangles(const char *meshName, int size, const int *vertices)
{
}

void precicec_setMeshQuad(const char *meshName, int firstVertexID, int secondVertexID, int thirdVertexID, int fourthVertexID)
{
}

void precicec_setMeshQuads(const char *meshName, int size, const int *vertices)
{
}

void precicec_setMeshTetrahedron(const char *meshName, int firstVertexID, int secondVertexID, int thirdVertexID, int fourthVertexID)
{
}

void precicec_setMeshTetrahedra(const char *meshName, int size, const int *vertices)
{
}

void precicec_writeData(const char *meshName, const char *dataName, int size, const int *valueIndices, const double *values)
{
    for (int i = 0; i < size * precicec_getMeshDimensions(meshName); i++)
    {

        fake_read_write_buffer[i] = values[i];
    }
}

void precicec_readData(const char *meshName, const char *dataName, int size, const int *valueIndices, double *values)
{
    for (int i = 0; i < size * precicec_getMeshDimensions(meshName); i++)
    {
        values[i] = fake_read_write_buffer[i];
    }
}

int precicec_requiresGradientDataFor(const char *meshName, const char *dataName)
{
    return 0;
}

void precicec_writeBlockVectorGradientData(const char *meshName, const char *dataName, int size, const int *valueIndices, const double *gradients)
{
    for (int i = 0; i < size * precicec_getMeshDimensions(meshName) * precicec_getMeshDimensions(meshName); i++)
    {
        fake_read_write_buffer[i] = gradients[i];
    }
}

const char *precicec_getVersionInformation()
{
    return "dummy";
}

void precicec_setMeshAccessRegion(const char *meshName, const double *boundingBox)
{
    // check meshname
    assert(strcmp(meshName, "FakeMesh") == 0);
    // check bounding box
    for (int i = 0; i < 2 * precicec_getMeshDimensions(meshName); i++)
    {
        assert(boundingBox[i] == fake_bounding_box[i]);
    }
}

void precicec_getMeshVerticesAndIDs(const char *meshName, const int size, int *ids, double *coordinates)
{
    assert(size == n_fake_vertices);
    assert(strcmp(meshName, "FakeMesh") == 0);
    for (int i = 0; i < size; i++)
    {
        ids[i] = fake_ids[i];
        coordinates[fake_dimensions * i] = i;
        coordinates[fake_dimensions * i + 1] = i + n_fake_vertices;
        coordinates[fake_dimensions * i + 2] = i + 2 * n_fake_vertices;
    }
}
